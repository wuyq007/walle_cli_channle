package com.demo.walle.cli.channle

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.meituan.android.walle.WalleChannelReader


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val channel = WalleChannelReader.getChannel(this.applicationContext)

        findViewById<TextView>(R.id.textView).apply {
            text = channel ?: "未获取到 walle channel"
        }
    }
}