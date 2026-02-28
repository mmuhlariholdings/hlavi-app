package app.hlavi.hlavi_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class RedirectUriReceiverActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // flutter_appauth handles the OAuth callback internally through its native code.
        // We just need to close this activity and return to MainActivity.
        // Do NOT forward the intent data, as that causes go_router to try to navigate to it.
        val redirectIntent = Intent(this, MainActivity::class.java)
        redirectIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        startActivity(redirectIntent)
        finish()
    }
}
