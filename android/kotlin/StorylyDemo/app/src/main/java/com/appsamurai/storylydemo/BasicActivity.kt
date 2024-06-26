package com.appsamurai.storylydemo

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.appsamurai.storyly.StorylyInit
import com.appsamurai.storyly.StorylyView
import com.appsamurai.storylydemo.databinding.ActivityMainBinding

class BasicActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.storylyView.storylyInit = StorylyInit(STORYLY_INSTANCE_TOKEN)

        val storylyView = StorylyView(this)
        storylyView.storylyInit = StorylyInit(STORYLY_INSTANCE_TOKEN)
        binding.storylyViewHolder.addView(storylyView)
    }
}
