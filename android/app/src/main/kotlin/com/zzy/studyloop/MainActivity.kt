package com.zzy.studyloop

import android.content.Context
import android.view.inputmethod.InputMethodManager
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val imeChannel = "com.zzy.studyloop/ime"
    private val integrityChannel = "com.zzy.studyloop/integrity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, imeChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "showSoftInput" -> {
                    try {
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                        val view = currentFocus ?: window.decorView
                        view.requestFocus()
                        view.post {
                            imm?.showSoftInput(view, InputMethodManager.SHOW_FORCED)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("IME_ERROR", e.message, null)
                    }
                }
                "hideSoftInput" -> {
                    try {
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                        val view = currentFocus ?: window.decorView
                        imm?.hideSoftInputFromWindow(view.windowToken, 0)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("IME_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, integrityChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestIntegrityToken" -> {
                    val requestHash = call.argument<String>("requestHash")
                    if (requestHash.isNullOrBlank()) {
                        result.error("INVALID_REQUEST", "requestHash is required", null)
                    } else {
                        requestIntegrityToken(requestHash, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestIntegrityToken(requestHash: String, result: MethodChannel.Result) {
        val cloudProjectNumber = BuildConfig.PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER.toLongOrNull()
        if (cloudProjectNumber == null) {
            result.error(
                "INTEGRITY_NOT_CONFIGURED",
                "Missing android/play-integrity.properties cloudProjectNumber",
                null,
            )
            return
        }

        val integrityManager = IntegrityManagerFactory.createStandard(applicationContext)
        val prepareRequest = StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
            .setCloudProjectNumber(cloudProjectNumber)
            .build()
        integrityManager.prepareIntegrityToken(prepareRequest)
            .addOnSuccessListener { provider ->
                val tokenRequest = StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                    .setRequestHash(requestHash)
                    .build()
                provider.request(tokenRequest)
                    .addOnSuccessListener { token -> result.success(token.token()) }
                    .addOnFailureListener { error ->
                        result.error("INTEGRITY_TOKEN_FAILED", error.message, null)
                    }
            }
            .addOnFailureListener { error ->
                result.error("INTEGRITY_PREPARE_FAILED", error.message, null)
            }
    }
}
