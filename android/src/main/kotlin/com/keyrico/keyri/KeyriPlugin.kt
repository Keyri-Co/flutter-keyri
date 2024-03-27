package com.keyrico.keyri

import androidx.annotation.NonNull
import android.net.Uri
import android.util.Log
import android.app.Activity
import android.content.Intent
import com.google.gson.Gson
import org.json.JSONObject
import com.keyrico.keyrisdk.Keyri
import com.keyrico.scanner.easyKeyriAuth
import com.keyrico.keyrisdk.exception.DenialException
import com.keyrico.keyrisdk.sec.fraud.event.EventType
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
import java.lang.Exception

class KeyriPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var keyri: Keyri

    private var activeSession: Session? = null

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
                val blockEmulatorDetection: Boolean = arguments?.get("blockEmulatorDetection")?.toBoolean() ?: true
//                val blockRootDetection: Boolean = arguments?.get("blockRootDetection")?.toBoolean() ?: false
//                val blockDangerousAppsDetection: Boolean = arguments?.get("blockDangerousAppsDetection")?.toBoolean() ?: false

                // TODO: Uncommnet when available
//                val blockTamperDetection: Boolean = arguments?.get("blockTamperDetection")?.toBoolean() ?: true
//                val blockTamperDetection: Boolean = true

//                val blockSwizzleDetection: Boolean = arguments?.get("blockSwizzleDetection")?.toBoolean() ?: false

                logMessage("Keyri: initialize called")
                initialize(
                    appKey,
                    publicApiKey,
                    serviceEncryptionKey,
                    blockEmulatorDetection,
//                    blockRootDetection,
//                    blockDangerousAppsDetection,
//                    blockTamperDetection,
//                    blockSwizzleDetection
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

                logMessage("Keyri: easyKeyriAuth called")
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

                logMessage("Keyri: generateAssociationKey called")
                generateAssociationKey(publicUserId, result)
            }

            "generateUserSignature" -> {
                val publicUserId = arguments?.get("publicUserId")
                val data = arguments?.get("data")

                logMessage("Keyri: generateUserSignature called")
                generateUserSignature(publicUserId, data, result)
            }

            "listAssociationKeys" -> {
                logMessage("Keyri: listAssociationKeys called")
                listAssociationKeys(result)
            }

            "listUniqueAccounts" -> {
                logMessage("Keyri: listUniqueAccounts called")
                listUniqueAccounts(result)
            }

            "getAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                logMessage("Keyri: getAssociationKey called")
                getAssociationKey(publicUserId, result)
            }

            "removeAssociationKey" -> {
                val publicUserId = arguments?.get("publicUserId")

                logMessage("Keyri: removeAssociationKey called")
                removeAssociationKey(publicUserId, result)
            }

            "sendEvent" -> {
                val publicUserId = arguments?.get("publicUserId")
                val eventType = arguments?.get("eventType")
                val metadata = arguments?.get("metadata")
                val success = arguments?.get("success")?.toBoolean()

                logMessage("Keyri: sendEvent called")
                sendEvent(publicUserId, eventType, metadata, success, result)
            }

            "createFingerprint" -> {
                logMessage("Keyri: createFingerprint called")
                createFingerprint(result)
            }

            "initiateQrSession" -> {
                val sessionId = arguments?.get("sessionId")
                val publicUserId = arguments?.get("publicUserId")

                logMessage("Keyri: initiateQrSession called")
                initiateQrSession(sessionId, publicUserId, result)
            }

            "login" -> {
                val publicUserId = arguments?.get("publicUserId")

                logMessage("Keyri: login called")
                login(publicUserId, result)
            }

            "register" -> {
                val publicUserId = arguments?.get("publicUserId")

                logMessage("Keyri: register called")
                register(publicUserId, result)
            }

            "getCorrectedTimestampSeconds" -> {
                logMessage("Keyri: getCorrectedTimestampSeconds called")
                getCorrectedTimestampSeconds(result)
            }

            "initializeDefaultConfirmationScreen" -> {
                logMessage("Keyri: initializeDefaultConfirmationScreen called")
                initializeDefaultConfirmationScreen(arguments?.get("payload"), result)
            }

            "processLink" -> {
                val link = arguments?.get("link")
                val payload = arguments?.get("payload")
                val publicUserId = arguments?.get("publicUserId")

                logMessage("Keyri: processLink called")
                processLink(link, payload, publicUserId, result)
            }

            "confirmSession" -> {
                val payload = arguments?.get("payload")
                val trustNewBrowser = arguments?.get("trustNewBrowser")?.toBoolean() ?: false

                logMessage("Keyri: confirmSession called")
                confirmSession(payload, trustNewBrowser, result)
            }

            "denySession" -> {
                logMessage("Keyri: confirmSession called")
                denySession(arguments?.get("payload"), result)
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
            logMessage("Keyri easyKeyriAuth success")
            easyKeyriAuthResult?.success(resultCode == Activity.RESULT_OK)
        }

        return requestCode == AUTH_REQUEST_CODE
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initialize(
        appKey: String?,
        publicApiKey: String?,
        serviceEncryptionKey: String?,
        blockEmulatorDetection: Boolean,
//        blockRootDetection: Boolean,
//        blockDangerousAppsDetection: Boolean,
//        blockTamperDetection: Boolean,
//        blockSwizzleDetection: Boolean,
        result: MethodChannel.Result
    ) {
        if (appKey == null) {
            logMessage("Keyri initialized: appKey must not be null")
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
                        // TODO: Add impl
//                        KeyriDetectionsConfig(
//                            blockEmulatorDetection,
//                            false,
//                            false,
//                            true,
//                            false,
//                        )
                    )
                }

                logMessage("Keyri initialized")
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
        if (appKey == null) {
            logMessage("Keyri easyKeyriAuth: appKey must not be null")
            result.error("easyKeyriAuth", "appKey must not be null", null)
        } else if (payload == null) {
            logMessage("Keyri easyKeyriAuth: payload must not be null")
            result.error("easyKeyriAuth", "payload must not be null", null)
        } else {
            activity?.let {
                easyKeyriAuth(
                    it,
                    AUTH_REQUEST_CODE,
                    appKey,
                    publicApiKey,
                    serviceEncryptionKey,
                    // TODO: Add impl
//                    blockEmulatorDetection,
                    payload,
                    publicUserId,
//                    detectionsConfig = KeyriDetectionsConfig()
                )

                easyKeyriAuthResult = result
            } ?: let {
                val message =
                    "To Use this method, make sure your host Activity extended from FlutterFragmentActivity"

                logMessage("Keyri easyKeyriAuth: $message")
                result.error("easyKeyriAuth", message, null)
            }
        }
    }

    private fun generateAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("generateAssociationKey", result::error).launch {
            val associationKey = publicUserId?.let {
                keyri.generateAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.generateAssociationKey().getOrThrow()

            logMessage("Keyri key generated: $associationKey")
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
                logMessage("Keyri generateUserSignature: data must not be null")
                result.error("generateUserSignature", "data must not be null", null)
            } else {
                val userSignature = publicUserId?.let {
                    keyri.generateUserSignature(it, data).getOrThrow()
                } ?: keyri.generateUserSignature(data = data).getOrThrow()

                logMessage("Keyri signature generated: $userSignature")
                result.success(userSignature)
            }
        }
    }

    private fun listAssociationKeys(result: MethodChannel.Result) {
        keyriCoroutineScope("listAssociationKeys", result::error).launch {
            val keys = keyri.listAssociationKeys().getOrThrow()

            logMessage("Keyri listAssociationKeys: ${keys.size} keys")
            result.success(keys)
        }
    }

    private fun listUniqueAccounts(result: MethodChannel.Result) {
        keyriCoroutineScope("listUniqueAccounts", result::error).launch {
            val keys = keyri.listUniqueAccounts().getOrThrow()

            logMessage("Keyri listUniqueAccounts: ${keys.size} keys")
            result.success(keys)
        }
    }

    private fun getAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("getAssociationKey", result::error).launch {
            val associationKey = publicUserId?.let {
                keyri.getAssociationKey(publicUserId).getOrThrow()
            } ?: keyri.getAssociationKey().getOrThrow()

            logMessage("Keyri getAssociationKey: $associationKey")
            result.success(associationKey)
        }
    }

    private fun removeAssociationKey(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("removeAssociationKey", result::error).launch {
            if (publicUserId == null) {
                logMessage("Keyri removeAssociationKey: publicUserId must not be null")
                result.error("removeAssociationKey", "publicUserId must not be null", null)
            } else {
                keyri.removeAssociationKey(publicUserId)
                logMessage("Keyri removeAssociationKey: success")
                result.success(true)
            }
        }
    }

    private fun sendEvent(
        publicUserId: String?,
        eventType: String?,
        metadata: String?,
        success: Boolean?,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("sendEvent", result::error).launch {
            val jsonMetadata = try {
                metadata?.let { JSONObject(it) }
            } catch (e: Exception) {
                null
            }

            val type = eventType?.let { EventType.custom(it, jsonMetadata) }

            if (success == null) {
                logMessage("Keyri sendEvent: success must not be null")
                result.error("sendEvent", "success must not be null", null)
            } else if (type == null) {
                logMessage("Keyri sendEvent: eventType must not be null")
                result.error("sendEvent", "eventType must not be null", null)
            } else {
                val userId = publicUserId ?: "ANON"

                keyri.sendEvent(userId, type, success).onSuccess { eventResponse ->
                    val eventResponse = Gson().toJson(eventResponse)

                    logMessage("Keyri sendEvent: $eventResponse")
                    result.success(eventResponse)
                }.onFailure {
                    logMessage("Keyri sendEvent: ${it.message}")
                    result.error("sendEvent", it.message, null)
                }
            }
        }
    }

    private fun createFingerprint(result: MethodChannel.Result) {
        keyriCoroutineScope("createFingerprint", result::error).launch {
            keyri.createFingerprint().onSuccess { fingerprint ->
                val fingerprintResponse = Gson().toJson(fingerprint)

                logMessage("Keyri createFingerprint: $fingerprintResponse")
                result.success(fingerprintResponse)
            }.onFailure {
                logMessage("Keyri createFingerprint: ${it.message}")
                result.error("createFingerprint", it.message, null)
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
                logMessage("Keyri initiateQrSession: sessionId must not be null")
                result.error("initiateQrSession", "sessionId must not be null", null)
            } else {
                keyri.initiateQrSession(sessionId, publicUserId).onSuccess { session ->
                    activeSession = session

                    val sessionResponse = Gson().toJson(session)

                    logMessage("Keyri initiateQrSession: $sessionResponse")
                    result.success(sessionResponse)
                }.onFailure {
                    logMessage("Keyri initiateQrSession: ${it.message}")
                    result.error("initiateQrSession", it.message, null)
                }
            }
        }
    }

    private fun login(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("login", result::error).launch {
            keyri.login(publicUserId).onSuccess { login ->
                val loginObject = Gson().toJson(login)

                logMessage("Keyri login: $loginObject")
                result.success(loginObject)
            }.onFailure {
                logMessage("Keyri login: ${it.message}")
                result.error("login", it.message, null)
            }
        }
    }

    private fun register(publicUserId: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("register", result::error).launch {
            keyri.register(publicUserId).onSuccess { register ->
                val registerObject = Gson().toJson(register)

                logMessage("Keyri register: $registerObject")
                result.success(registerObject)
            }.onFailure {
                logMessage("Keyri register: ${it.message}")
                result.error("register", it.message, null)
            }
        }
    }

    private fun getCorrectedTimestampSeconds(result: MethodChannel.Result) {
        keyriCoroutineScope("getCorrectedTimestampSeconds", result::error).launch {
            val correctedTimestampSeconds = keyri.getCorrectedTimestampSeconds()

            logMessage("Keyri getCorrectedTimestampSeconds: $correctedTimestampSeconds")
            result.success(correctedTimestampSeconds)
        }
    }

    private fun initializeDefaultConfirmationScreen(
        payload: String?,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("initializeDefaultConfirmationScreen", result::error).launch {
            if (activeSession == null) {
                logMessage("Keyri initializeDefaultConfirmationScreen: can't find session")
                result.error("initializeDefaultConfirmationScreen", "Can't find session", null)
            } else if (payload == null) {
                logMessage("Keyri initializeDefaultConfirmationScreen: payload must not be null")
                result.error(
                    "initializeDefaultConfirmationScreen",
                    "payload must not be null",
                    null
                )
            } else {
                (activity as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.initializeDefaultConfirmationScreen(
                        fm,
                        requireNotNull(activeSession),
                        payload
                    ).getOrThrow()
                    logMessage("Keyri initializeDefaultConfirmationScreen: success")
                    result.success(true)
                } ?: let {
                    val message =
                        "To Use this method, make sure your host Activity extended from FlutterFragmentActivity"

                    logMessage("Keyri initializeDefaultConfirmationScreen: $message")
                    result.error("initializeDefaultConfirmationScreen", message, null)
                }
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
                logMessage("Keyri processLink: link must not be null")
                result.error("processLink", "link must not be null", null)
            } else if (payload == null) {
                logMessage("Keyri processLink: payload must not be null")
                result.error("processLink", "payload must not be null", null)
            } else {
                (activity as? FragmentActivity)?.supportFragmentManager?.let { fm ->
                    keyri.processLink(fm, Uri.parse(link), payload, publicUserId).getOrThrow()
                    logMessage("Keyri processLink: success")
                    result.success(true)
                }
            }
        }
    }

    private fun confirmSession(
        payload: String?,
        trustNewBrowser: Boolean,
        result: MethodChannel.Result
    ) {
        keyriCoroutineScope("confirmSession", result::error).launch {
            if (activeSession == null) {
                logMessage("Keyri confirmSession: can't find session")
                result.error("confirmSession", "Can't find session", null)
            } else if (payload == null) {
                logMessage("Keyri confirmSession: payload must not be null")
                result.error("confirmSession", "payload must not be null", null)
            } else {
                requireNotNull(activeSession).confirm(
                    payload,
                    requireNotNull(activity),
                    trustNewBrowser
                ).onSuccess {
                    logMessage("Keyri confirmSession: success")
                    result.success(true)
                }.onFailure {
                    logMessage("Keyri confirmSession: ${it.message}")
                    result.error("confirmSession", it.message, null)
                }
            }
        }
    }

    private fun denySession(payload: String?, result: MethodChannel.Result) {
        keyriCoroutineScope("denySession", result::error).launch {
            if (activeSession == null) {
                logMessage("Keyri denySession: can't find session")
                result.error("denySession", "Can't find session", null)
            } else if (payload == null) {
                logMessage("Keyri denySession: payload must not be null")
                result.error("denySession", "payload must not be null", null)
            } else {
                requireNotNull(activeSession).deny(payload, requireNotNull(activity)).onSuccess {
                    logMessage("Keyri denySession: success")
                    result.success(true)
                }.onFailure {
                    logMessage("Keyri denySession: ${it.message}")
                    result.error("denySession", it.message, null)
                }
            }
        }
    }

    private fun logMessage(message: String) {
        Log.d(CHANNEL, message)
    }

    private fun keyriCoroutineScope(
        methodName: String,
        errorCallback: (errorCode: String, errorMessage: String, errorDetails: Any?) -> Unit
    ): CoroutineScope {
        val exceptionHandler = CoroutineExceptionHandler { _, e ->
            val message = e.message ?: "Error calling $methodName method"

            Log.e(CHANNEL, message, e)

            errorCallback(methodName, message, null)
        }

        return CoroutineScope(Dispatchers.IO + exceptionHandler)
    }

    companion object {
        private const val AUTH_REQUEST_CODE = 2133

        private const val CHANNEL = "keyri"
    }
}
