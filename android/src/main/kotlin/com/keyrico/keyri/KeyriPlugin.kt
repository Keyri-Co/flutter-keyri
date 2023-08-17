package com.keyrico.keyri

import androidx.annotation.NonNull
import android.net.Uri
import android.app.Activity
import android.content.Intent
import com.google.gson.Gson
import com.keyrico.keyrisdk.Keyri
import com.keyrico.scanner.easyKeyriAuth
import com.keyrico.keyrisdk.exception.DenialException
import com.keyrico.keyrisdk.sec.fraud.enums.EventType
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

    private val sessions = mutableListOf<Session>()

    private var easyKeyriAuthResult: MethodChannel.Result? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val arguments = call.arguments() as? Map<String, String?>?

        when (call.method) {
            "initialize" -> {
                val appKey = arguments?.get("appKey")
                val publicApiKey = arguments?.get("publicApiKey")
                val serviceEncryptionKey = arguments?.get("serviceEncryptionKey")
                val blockEmulatorDetection =
                    arguments?.get("blockEmulatorDetection")?.toBoolean() ?: true

                initialize(
                    appKey,
                    publicApiKey,
                    serviceEncryptionKey,
                    blockEmulatorDetection,
                    result
                )
            }

            "easyKeyriAuth" -> {
                val appKey = arguments?.get("appKey")
                val publicApiKey = arguments?.get("publicApiKey")
                val serviceEncryptionKey = arguments?.get("serviceEncryptionKey")
                val blockEmulatorDetection =
                    arguments?.get("blockEmulatorDetection")?.toBoolean() ?: true
                val payload = arguments?.get("payload")
                val publicUserId = arguments?.get("publicUserId")

                easyKeyriAuth(
                    appKey,
                    publicApiKey,
                    serviceEncryptionKey,
                    blockEmulatorDetection,
                    payload,
                    publicUserId,
                    result
                )
            }

            "generateAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                generateAssociationKey(publicUserId, result)
            }

            "generateUserSignature" -> {
                val publicUserId = arguments?.get("publicUserId")
                val data = arguments?.get("data")

                generateUserSignature(publicUserId, data, result)
            }

            "listAssociationKeys" -> listAssociationKeys(result)
            "listUniqueAccounts" -> listUniqueAccounts(result)
            "getAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                getAssociationKey(publicUserId, result)
            }

            "removeAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                removeAssociationKey(publicUserId, result)
            }

            "sendEvent" -> {
                val publicUserId = arguments?.get("publicUserId")
                val eventType = arguments?.get("eventType")
                val success = arguments?.get("success")?.toBoolean() ?: true

                sendEvent(publicUserId, eventType, success, result)
            }

            "initiateQrSession" -> {
                val sessionId = arguments?.get("sessionId")
                val publicUserId = arguments?.get("publicUserId")

                initiateQrSession(sessionId, publicUserId, result)
            }

            "initializeDefaultConfirmationScreen" -> {
                val sessionId = arguments?.get("sessionId")
                val payload = arguments?.get("payload")

                initializeDefaultScreen(sessionId, payload, result)
            }

            "processLink" -> {
                val link = arguments?.get("link")
                val payload = arguments?.get("payload")
                val publicUserId = arguments?.get("publicUserId")

                processLink(link, payload, publicUserId, result)
            }

            "confirmSession" -> {
                val sessionId = arguments?.get("sessionId")
                val payload = arguments?.get("payload")
                val trustNewBrowser = arguments?.get("trustNewBrowser")?.toBoolean() ?: false

                confirmSession(sessionId, payload, trustNewBrowser, result)
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
            easyKeyriAuthResult?.success(resultCode == Activity.RESULT_OK)
        }

        return false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initialize(
        appKey: String?,
        publicApiKey: String?,
        serviceEncryptionKey: String?,
        blockEmulatorDetection: Boolean,
        result: MethodChannel.Result
    ) {
        if (appKey == null) {
            result.error("initialize", "appKey must not be null", null)
        } else {
            activity?.let {
                if (!this::keyri.isInitialized) {
                    keyri = Keyri(
                        it,
                        appKey,
                        publicApiKey,
                        serviceEncryptionKey,
                        blockEmulatorDetection
                    )
                }

                result.success(true)
            }
        }
    }

    private fun easyKeyriAuth(
        appKey: String?,
        publicApiKey: String?,
        serviceEncryptionKey: String?,
        blockEmulatorDetection: Boolean,
        payload: String?,
        publicUserId: String?,
        result: MethodChannel.Result
    ) {
        if (appKey == null || payload == null) {
            result.error("easyKeyriAuth", "appKey and payload must not be null", null)
        } else {
            activity?.let {
                easyKeyriAuth(
                    it,
                    AUTH_REQUEST_CODE,
                    appKey,
                    publicApiKey,
                    serviceEncryptionKey,
                    blockEmulatorDetection,
                    payload,
                    publicUserId
                )

                easyKeyriAuthResult = result
            } ?: result.error(
                "easyKeyriAuth",
                "To Use this method, make sure your host Activity extended from FlutterFragmentActivity",
                null
            )
        }
    }

    private fun generateAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("generateAssociationKey", result::error).launch {
            val associationKey = publicUserId?.let {
                keyri.generateAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.generateAssociationKey().getOrThrow()

            result.success(associationKey)
        }
    }

    private fun generateUserSignature(
        publicUserId: String?,
        data: String?,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("generateUserSignature", result::error).launch {
            if (data == null) {
                result.error("generateUserSignature", "data must not be null", null)
            } else {
                val userSignature = publicUserId?.let {
                    keyri.generateUserSignature(it, data).getOrThrow()
                } ?: keyri.generateUserSignature(data = data).getOrThrow()

                result.success(userSignature)
            }
        }
    }

    private fun listAssociationKeys(result: MethodChannel.Result) {
        keyriCoroutineScope("listAssociationKeys", result::error).launch {
            result.success(keyri.listAssociationKeys().getOrThrow())
        }
    }

    private fun listUniqueAccounts(result: MethodChannel.Result) {
        keyriCoroutineScope("listUniqueAccounts", result::error).launch {
            result.success(keyri.listUniqueAccounts().getOrThrow())
        }
    }

    private fun getAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("getAssociationKey", result::error).launch {
            val associationKey = publicUserId?.let {
                keyri.getAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.getAssociationKey().getOrThrow()

            result.success(associationKey)
        }
    }

    private fun removeAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("removeAssociationKey", result::error).launch {
            if (publicUserId == null) {
                result.error("removeAssociationKey", "publicUserId must not be null", null)
            } else {
                keyri.removeAssociationKey(publicUserId)
                result.success(true)
            }
        }
    }

    private fun sendEvent(
        publicUserId: String?,
        eventType: String?,
        success: Boolean,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("sendEvent", result::error).launch {
            val type = EventType.values().firstOrNull { it.type == eventType }

            if (type == null) {
                result.error("sendEvent", "eventType must not be null", null)
            } else {
                val userId = if (publicUserId == null) "ANON" else publicUserId

                keyri.sendEvent(userId, type, success).onSuccess { eventResponse ->
                    result.success(Gson().toJson(eventResponse))
                }.onFailure {
                    result.error("sendEvent", it.message, null)
                }
            }
        }
    }

    private fun initiateQrSession(
        sessionId: String?,
        publicUserId: String?,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("initiateQrSession", result::error).launch {
            if (sessionId == null) {
                result.error("initiateQrSession", "sessionId must not be null", null)
            } else {
                keyri.initiateQrSession(sessionId, publicUserId).onSuccess { session ->
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
        keyriCoroutineScope("initializeDefaultScreen", result::error).launch {
            val session = findSession(sessionId)

            if (session == null) {
                result.error("initializeDefaultScreen", "Can't find session", null)
            } else if (payload == null) {
                result.error("initializeDefaultScreen", "payload must not be null", null)
            } else {
                (activity as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.initializeDefaultConfirmationScreen(fm, session, payload).getOrThrow()
                    result.success(true)
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
        payload: String?,
        publicUserId: String?,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("processLink", result::error).launch {
            if (link == null) {
                result.error("processLink", "link must not be null", null)
            } else if (payload == null) {
                result.error("processLink", "payload must not be null", null)
            } else {
                (activity as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.processLink(fm, Uri.parse(link), payload, publicUserId)
                    result.success(true)
                }
            }
        }
    }

    private fun confirmSession(sessionId: String?, payload: String?, trustNewBrowser: Boolean, result: MethodChannel.Result) {
        keyriCoroutineScope("confirmSession", result::error).launch {
            val session = findSession(sessionId)

            if (session == null) {
                result.error("confirmSession", "Can't find session", null)
            } else if (payload == null) {
                result.error("confirmSession", "payload must not be null", null)
            } else {
                session.confirm(payload, requireNotNull(activity), trustNewBrowser).onSuccess {
                    result.success(true)
                }.onFailure {
                    result.error("confirmSession", it.message, null)
                }
            }
        }
    }

    private fun denySession(sessionId: String?, payload: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("denySession", result::error).launch {
            val session = findSession(sessionId)

            if (session == null) {
                result.error("denySession", "Can't find session", null)
            } else if (payload == null) {
                result.error("denySession", "payload must not be null", null)
            } else {
                session.deny(payload, requireNotNull(activity)).onSuccess {
                    result.success(true)
                }.onFailure {
                    result.error("denySession", it.message, null)
                }
            }
        }
    }

    private fun findSession(sessionId: String?): Session? =
        sessions.firstOrNull { it.sessionId == sessionId }

    private fun keyriCoroutineScope(
        methodName: String,
        errorCallback: (errorCode: String, errorMessage: String, errorDetails: Any?) -> Unit
    ): CoroutineScope {
        val exceptionHandler = CoroutineExceptionHandler { _, e ->
            errorCallback(methodName, e.message ?: "Error calling $methodName method", null)
        }

        return CoroutineScope(Dispatchers.IO + exceptionHandler)
    }

    companion object {
        private const val AUTH_REQUEST_CODE = 2133

        private const val CHANNEL = "keyri"
    }
}
