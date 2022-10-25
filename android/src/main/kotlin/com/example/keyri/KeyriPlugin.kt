package com.example.keyri

import androidx.annotation.NonNull
import android.net.Uri
import android.app.Activity
import android.content.Intent
import com.google.gson.Gson
import com.keyrico.keyrisdk.Keyri
import com.keyrico.scanner.easyKeyriAuth
import com.keyrico.keyrisdk.exception.DenialException
import androidx.fragment.app.FragmentActivity
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

    private lateinit var keyri: Keyri

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
                val payload = arguments?.get("payload")
                val publicUserId = arguments?.get("publicUserId")

                easyKeyriAuth(appKey, payload, publicUserId, result)
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
            "processLink" -> {
                val link = arguments?.get("link")
                val appKey = arguments?.get("appKey")
                val payload = arguments?.get("payload")
                val publicUserId = arguments?.get("publicUserId")

                processLink(link, appKey, payload, publicUserId, result)
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
        keyri = Keyri(binding.activity)

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
        payload: String?,
        publicUserId: String?,
        result: MethodChannel.Result
    ) {
        if (appKey == null || payload == null) {
            result.error("easyKeyriAuth", "appKey and payload must not be null", null)
        } else {
            activity?.let {
                easyKeyriAuth(it, AUTH_REQUEST_CODE, appKey, payload, publicUserId)

                easyKeyriAuthResult = result
            } ?: result.error(
                "initializeDefaultScreen",
                "To Use this method, make sure your host Activity extended from FlutterFragmentActivity",
                null
            )
        }
    }

    private fun generateAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        val associationKey = publicUserId?.let {
            keyri.generateAssociationKey(publicUserId)
        } ?: keyri.generateAssociationKey()

        result.success(associationKey)
    }

    private fun getUserSignature(
        publicUserId: String?,
        customSignedData: String?,
        result: MethodChannel.Result
    ) {
        if (customSignedData == null) {
            result.error("getUserSignature", "customSignedData must not be null", null)
        } else {
            val userSignature = publicUserId?.let {
                keyri.generateUserSignature(it, customSignedData)
            } ?: keyri.generateUserSignature(data = customSignedData)

            result.success(userSignature)
        }
    }

    private fun listAssociationKey(result: MethodChannel.Result) {
        result.success(keyri.listAssociationKey())
    }

    private fun getAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        val associationKey = publicUserId?.let {
            keyri.getAssociationKey(publicUserId)
        } ?: keyri.getAssociationKey()

        result.success(associationKey)
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
                    keyri.initializeDefaultConfirmationScreen(fm, session, payload)
                        .onSuccess { authResult ->
                            result.success(authResult == "success")
                        }.onFailure {
                            if (it !is DenialException) {
                                result.error("initializeDefaultScreen", it.message, null)
                            } else {
                                result.success(false)
                            }
                        }
                } ?: result.error(
                    "initializeDefaultScreen",
                    "To Use this method, make sure your host Activity extended from FlutterFragmentActivity",
                    null
                )
            }
        }
    }

    private fun processLink(
        link: String?,
        appKey: String?,
        payload: String?,
        publicUserId: String?,
        result: MethodChannel.Result
    ) {
        mainScope.launch {
            if (link == null) {
                result.error("processLink", "link must not be null", null)
            } else if (appKey == null) {
                result.error("processLink", "appKey must not be null", null)
            } else if (payload == null) {
                result.error("processLink", "payload must not be null", null)
            } else {
                (activity as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    val uri = Uri.parse(link)

                    keyri.processLink(fm, uri, appKey, payload, publicUserId)
                        .onSuccess { authResult ->
                            result.success(authResult == "success")
                        }.onFailure {
                            if (it !is DenialException) {
                                result.error("processLink", it.message, null)
                            } else {
                                result.success(false)
                            }
                        }
                }
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
