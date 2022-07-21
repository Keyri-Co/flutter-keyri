package com.example.keyri

import androidx.annotation.NonNull

import android.app.Activity
import android.content.Intent
import com.google.gson.Gson
import com.keyrico.keyrisdk.Keyri
import androidx.fragment.app.FragmentActivity
import com.keyrico.keyrisdk.ui.auth.AuthWithScannerActivity
import com.keyrico.keyrisdk.entity.session.Session
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.launch
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class KeyriPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel

    private val keyri by lazy(::Keyri)

    private val mainScope = CoroutineScope(Dispatchers.Main)

    private var easyKeyriAuthResult: MethodChannel.Result? = null

    private var activity: Activity? = null

    private val sessions = mutableListOf<Session>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val arguments = call.arguments() as? Map<String, String?>?

        when (call.method) {
            "easyKeyriAuth" -> {
                val appKey = arguments?.get("appKey")
                val publicUserId = arguments?.get("publicUserId")
                val payload = arguments?.get("payload")

                easyKeyriAuth(appKey, publicUserId, payload, result)
            }
            "generateAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                generateAssociationKey(publicUserId, result)
            }
            "getUserSignature" -> {
                val publicUserId = arguments?.get("publicUserId")
                val customSignedData = arguments?.get("customSignedData")

                getUserSignature(publicUserId, customSignedData, result)
            }
            "listAssociationKey" -> listAssociationKey(result)
            "getAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                getAssociationKey(publicUserId, result)
            }
            "initiateQrSession" -> {
                val appKey = arguments?.get("appKey")
                val sessionId = arguments?.get("sessionId")
                val publicUserId = arguments?.get("publicUserId")

                initiateQrSession(appKey, sessionId, publicUserId, result)
            }
            "initializeDefaultScreen" -> {
                val sessionId = arguments?.get("sessionId")
                val payload = arguments?.get("payload")

                initializeDefaultScreen(sessionId, payload, result)
            }
            "confirmSession" -> {
                val sessionId = arguments?.get("sessionId")
                val payload = arguments?.get("payload")

                confirmSession(sessionId, payload, result)
            }
            "denySession" -> {
                val sessionId = arguments?.get("sessionId")
                val payload = arguments?.get("payload")

                denySession(sessionId, payload, result)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = Unit

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() = Unit

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == AUTH_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                easyKeyriAuthResult?.success(resultCode == Activity.RESULT_OK)
            }
        }

        return false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun easyKeyriAuth(
        appKey: String?,
        publicUserId: String?,
        payload: String?,
        result: MethodChannel.Result
    ) {
        if (appKey == null || payload == null) {
            result.error("easyKeyriAuth", "appKey and payload must not be null", null)
        } else {
            activity?.let {
                val intent = Intent(it, AuthWithScannerActivity::class.java).apply {
                    putExtra(AuthWithScannerActivity.APP_KEY, appKey)
                    putExtra(AuthWithScannerActivity.PUBLIC_USER_ID, publicUserId)
                    putExtra(AuthWithScannerActivity.PAYLOAD, payload)
                }

                it.startActivityForResult(intent, AUTH_REQUEST_CODE)

                easyKeyriAuthResult = result
            } ?: result.error(
                "initializeDefaultScreen",
                "To Use this method, make sure your host Activity extended from FlutterFragmentActivity",
                null
            )
        }
    }

    private fun generateAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        if (publicUserId == null) {
            result.error("generateAssociationKey", "publicUserId must not be null", null)
        } else {
            result.success(keyri.generateAssociationKey(publicUserId))
        }
    }

    private fun getUserSignature(
        publicUserId: String?,
        customSignedData: String?,
        result: MethodChannel.Result
    ) {
        if (customSignedData == null) {
            result.error("getUserSignature", "publicUserId must not be null", null)
        } else {
            result.success(keyri.getUserSignature(publicUserId, customSignedData))
        }
    }

    private fun listAssociationKey(result: MethodChannel.Result) {
        result.success(keyri.listAssociationKey())
    }

    private fun getAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        result.success(keyri.getAssociationKey(publicUserId))
    }

    private fun initiateQrSession(
        appKey: String?,
        sessionId: String?,
        publicUserId: String?,
        result: MethodChannel.Result
    ) {
        mainScope.launch {
            if (sessionId == null || appKey == null) {
                result.error("initiateQrSession", "appKey and sessionId must not be null", null)
            } else {
                keyri.initiateQrSession(appKey, sessionId, publicUserId).onSuccess { session ->
                    sessions.add(session)

                    result.success(Gson().toJson(session))
                }.onFailure {
                    result.error("initiateQrSession", it.message, null)
                }
            }
        }
    }

    private fun initializeDefaultScreen(
        sessionId: String?,
        payload: String?,
        result: MethodChannel.Result
    ) {
        mainScope.launch {
            val session = findSession(sessionId)

            if (session == null) {
                result.error("initializeDefaultScreen", "Can't find session", null)
            } else if (payload == null) {
                result.error("initializeDefaultScreen", "payload must not be null", null)
            } else {
                (activity as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.initializeDefaultScreen(fm, session, payload)
                        .onSuccess { isAuthenticated ->
                            result.success(isAuthenticated)
                        }.onFailure {
                            result.error("initializeDefaultScreen", it.message, null)
                        }
                } ?: result.error(
                    "initializeDefaultScreen",
                    "To Use this method, make sure your host Activity extended from FlutterFragmentActivity",
                    null
                )
            }
        }
    }

    private fun confirmSession(sessionId: String?, payload: String?, result: MethodChannel.Result) {
        mainScope.launch {
            val session = findSession(sessionId)

            if (session == null) {
                result.error("confirmSession", "Can't find session", null)
            } else if (payload == null) {
                result.error("confirmSession", "payload must not be null", null)
            } else {
                session.confirm(payload).onSuccess { confirmationResult ->
                    result.success(confirmationResult)
                }.onFailure {
                    result.error("confirmSession", it.message, null)
                }
            }
        }
    }

    private fun denySession(sessionId: String?, payload: String?, result: MethodChannel.Result) {
        mainScope.launch {
            val session = findSession(sessionId)

            if (session == null) {
                result.error("denySession", "Can't find session", null)
            } else if (payload == null) {
                result.error("denySession", "payload must not be null", null)
            } else {
                session.deny(payload).onSuccess { denialResult ->
                    result.success(denialResult)
                }.onFailure {
                    result.error("denySession", it.message, null)
                }
            }
        }
    }

    private fun findSession(sessionId: String?): Session? =
        sessions.firstOrNull { it.sessionId == sessionId }

    companion object {
        private const val AUTH_REQUEST_CODE = 2133

        private const val CHANNEL = "keyri"
    }
}