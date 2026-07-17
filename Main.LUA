require "import"
import "android.widget.*"
import "android.content.Context"
import "android.media.AudioManager"
import "android.content.Intent"
import "android.net.Uri"
import "android.os.Vibrator"

-- Layout for the main dialog
layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    {
        LinearLayout,
        orientation = "horizontal",
        layout_width = "fill",
        layout_height = "wrap",
        {
            TextView,
            text = "Smart Volume Controller",
            layout_width = "0dp",
            layout_height = "wrap",
            layout_weight = 1,
            gravity = "center",
            textSize = 22,
            padding = "12dp",
        },
        {
            Button,
            id = "menuButton",
            text = "More Options",
            layout_width = "wrap",
            layout_height = "wrap",
            padding = "12dp",
            onClick = function()
                showMenuDialog()
            end
        }
    },
    {
        GridView,
        id = "grid",
        numColumns = 1,
        layout_width = "fill",
        layout_height = "0dp",
        layout_weight = 1,
    }
}

-- Volume item names
items = {
    "Media Volume",
    "Call Volume",
    "Alarm Volume",
    "Accessibility Volume",
    "Notification Volume",
    "Ringtone Volume",
    "System Volume",
    "Bluetooth Volume",
    "Dial Pad Volume",
    "Assistant Volume",
    "Voice Assistant Volume",
    "Background Music Volume",
    "Keyboard Sound Volume",
}

-- Default settings
local tickSoundEnabled = true
local vibrationEnabled = true
local vibrationIntensity = 50
local vibrator = this.getSystemService(Context.VIBRATOR_SERVICE)

-- Main dialog
dlg = LuaDialog(this)
dlg.View = loadlayout(layout)
dlg.setTitle("Smart Volume Controller")
dlg.setButton("Close", nil)
dlg.show()

-- Adapter for grid view
grid.adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, items)

-- Item click handling
grid.onItemClick = function(l, v)
    if vibrationEnabled then
        vibrator.vibrate(vibrationIntensity)
    end
    if tickSoundEnabled then
        service.playSoundTick()
    end
    local audioManager = this.getSystemService(Context.AUDIO_SERVICE)
    local streamTypes = {
        AudioManager.STREAM_MUSIC,
        AudioManager.STREAM_VOICE_CALL,
        AudioManager.STREAM_ALARM,
        AudioManager.STREAM_ACCESSIBILITY,
        AudioManager.STREAM_NOTIFICATION,
        AudioManager.STREAM_RING,
        AudioManager.STREAM_SYSTEM,
        AudioManager.STREAM_BLUETOOTH_SCO,
        AudioManager.STREAM_DTMF,
        AudioManager.STREAM_VOICE_CALL,
        AudioManager.STREAM_VOICE_CALL,
        AudioManager.STREAM_MUSIC,
        AudioManager.STREAM_MUSIC,
    }
    local position = grid.pointToPosition(v.getX(), v.getY())
    showVolumeSlider(audioManager, streamTypes[position + 1], items[position + 1])
end

-- Function to show menu dialog
function showMenuDialog()
    local menuLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "More Options",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
            padding = "12dp",
        },
        {
            Button,
            text = "Settings",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                menuDlg.dismiss()
                showSettingsDialog()
            end
        },
        {
            Button,
            text = "Feedback",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                menuDlg.dismiss()
                showFeedbackDialog()
            end
        },
        {
            Button,
            text = "About",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                menuDlg.dismiss()
                showAboutDialog()
            end
        }
    }
    menuDlg = LuaDialog(this)
    menuDlg.View = loadlayout(menuLayout)
    menuDlg.setTitle("More Options")
    menuDlg.setButton("Close", nil)
    menuDlg.show()
end

-- Function to show volume sliders
function showVolumeSlider(audioManager, streamType, title)
    local maxVolume = audioManager.getStreamMaxVolume(streamType)
    local currentVolume = audioManager.getStreamVolume(streamType)
    local sliderLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        {
            TextView,
            text = title,
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
        },
        {
            SeekBar,
            id = "volumeSlider",
            max = maxVolume,
            progress = currentVolume,
            layout_width = "fill",
            layout_height = "wrap",
        }
    }
    local volumeDlg = LuaDialog(this)
    volumeDlg.View = loadlayout(sliderLayout)
    volumeDlg.setTitle(title)
    volumeDlg.setButton("Close", nil)
    volumeDlg.show()
    volumeSlider.setOnSeekBarChangeListener{
        onProgressChanged = function(seekBar, progress)
            audioManager.setStreamVolume(streamType, progress, AudioManager.FLAG_SHOW_UI)
            local volumePercentage = math.floor((progress / maxVolume) * 100)
            service.speak(tostring(volumePercentage) .. "% " .. title)
            if tickSoundEnabled then
                service.playSoundTick()
            end
            if vibrationEnabled then
                vibrator.vibrate(vibrationIntensity)
            end
        end,
        onStartTrackingTouch = function(seekBar) end,
        onStopTrackingTouch = function(seekBar) end
    }
end

-- Function to show settings dialog
function showSettingsDialog()
    local settingsLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "Settings",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
            padding = "16dp",
        },
        {
            LinearLayout,
            orientation = "horizontal",
            layout_width = "fill",
            layout_height = "wrap",
            {
                TextView,
                text = "Tick Sound:",
                layout_width = "0dp",
                layout_height = "wrap",
                layout_weight = 1,
                textSize = 16,
                padding = "8dp",
            },
            {
                ToggleButton,
                id = "tickSoundToggle",
                textOn = "ON",
                textOff = "OFF",
                layout_width = "wrap",
                layout_height = "wrap",
                checked = tickSoundEnabled,
            }
        },
        {
            LinearLayout,
            orientation = "horizontal",
            layout_width = "fill",
            layout_height = "wrap",
            {
                TextView,
                text = "Vibration:",
                layout_width = "0dp",
                layout_height = "wrap",
                layout_weight = 1,
                textSize = 16,
                padding = "8dp",
            },
            {
                ToggleButton,
                id = "vibrationToggle",
                textOn = "ON",
                textOff = "OFF",
                layout_width = "wrap",
                layout_height = "wrap",
                checked = vibrationEnabled,
            }
        },
        {
            LinearLayout,
            orientation = "horizontal",
            layout_width = "fill",
            layout_height = "wrap",
            {
                TextView,
                text = "Vibration Intensity:",
                layout_width = "0dp",
                layout_height = "wrap",
                layout_weight = 1,
                textSize = 16,
                padding = "8dp",
            },
            {
                SeekBar,
                id = "intensitySeekBar",
                max = 100,
                progress = vibrationIntensity,
                layout_width = "0dp",
                layout_height = "wrap",
                layout_weight = 1,
            }
        },
        {
            Button,
            text = "Save Settings",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                tickSoundEnabled = tickSoundToggle.isChecked()
                vibrationEnabled = vibrationToggle.isChecked()
                vibrationIntensity = intensitySeekBar.getProgress()
                settingsDlg.dismiss()
            end
        }
    }
    settingsDlg = LuaDialog(this)
    settingsDlg.View = loadlayout(settingsLayout)
    settingsDlg.setTitle("Settings")
    settingsDlg.setButton("Close", nil)
    settingsDlg.show()
    
    -- Update intensity value when seekbar changes
    intensitySeekBar.setOnSeekBarChangeListener{
        onProgressChanged = function(seekBar, progress, fromUser)
            service.speak("Intensity: " .. progress .. " percent")
        end
    }
end

-- Function to show feedback dialog
function showFeedbackDialog()
    local feedbackLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "Provide Your Feedback",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
            padding = "8dp",
        },
        {
            TextView,
            text = "Your Name:",
            layout_width = "fill",
            layout_height = "wrap",
            textSize = 14,
            padding = "4dp",
        },
        {
            EditText,
            id = "nameInput",
            hint = "Enter your full name",
            layout_width = "fill",
            layout_height = "wrap",
            padding = "8dp",
        },
        {
            TextView,
            text = "Gender:",
            layout_width = "fill",
            layout_height = "wrap",
            textSize = 14,
            padding = "4dp",
        },
        {
            Spinner,
            id = "genderSpinner",
            layout_width = "fill",
            layout_height = "wrap",
        },
        {
            TextView,
            text = "Your Feedback:",
            layout_width = "fill",
            layout_height = "wrap",
            textSize = 14,
            padding = "4dp",
        },
        {
            EditText,
            id = "feedbackInput",
            hint = "Type your feedback here...",
            layout_width = "fill",
            layout_height = "wrap",
            padding = "8dp",
            minLines = 4,
        },
        {
            Button,
            text = "Send Feedback",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                sendFeedback()
            end
        }
    }
    feedbackDlg = LuaDialog(this)
    feedbackDlg.View = loadlayout(feedbackLayout)
    feedbackDlg.setTitle("Feedback")
    feedbackDlg.setButton("Close", nil)
    feedbackDlg.show()
    
    -- Setup gender spinner with adapter
    local genderItems = {"Select Gender", "Male", "Female", "Other"}
    local adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, genderItems)
    adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
    genderSpinner.setAdapter(adapter)
end

-- Function to send feedback
function sendFeedback()
    local nameView = feedbackDlg.findViewById(nameInput.getId())
    local genderView = feedbackDlg.findViewById(genderSpinner.getId())
    local feedbackView = feedbackDlg.findViewById(feedbackInput.getId())
    
    local name = nameView.getText().toString()
    local gender = genderView.getSelectedItem()
    local feedbackText = feedbackView.getText().toString()
    
    if gender == nil or gender == "" then
        service.speak("Please select your gender")
        return
    end
    
    if name == "" then
        service.speak("Please enter your name")
        return
    end
    
    if gender == "Select Gender" then
        service.speak("Please select your gender")
        return
    end
    
    if feedbackText == "" then
        service.speak("Please enter your feedback")
        return
    end
    
    local fullMessage = "Name: " .. name .. "\nGender: " .. gender .. "\n\nFeedback:\n" .. feedbackText
    
    -- Send directly to WhatsApp
    local number = "9118141191"
    local url = "https://wa.me/" .. number .. "?text=" .. Uri.encode(fullMessage)
    local intent = Intent(Intent.ACTION_VIEW)
    intent.setData(Uri.parse(url))
    this.startActivity(intent)
    
    feedbackDlg.dismiss()
end

-- Function to show About dialog
function showAboutDialog()
    local aboutLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "About Smart Volume Controller",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 22,
            padding = "8dp",
        },
        {
            TextView,
            text = "Version: 1.0",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 16,
            padding = "4dp",
        },
        {
            TextView,
            text = "Smart Volume Controller is an advanced audio management tool that allows you to control all audio streams of your Android device with ease. It provides a user-friendly interface with quick access to volume controls, haptic feedback, and audio feedback.",
            layout_width = "fill",
            layout_height = "wrap",
            padding = "12dp",
            textSize = 14,
        },
        {
            TextView,
            text = "Features:",
            layout_width = "fill",
            layout_height = "wrap",
            textSize = 16,
            padding = "8dp",
        },
        {
            TextView,
            text = "Control 13 different audio streams\nReal-time volume percentage feedback\nHaptic vibration support\nAudio tick feedback\nQuick settings access\nFeedback system",
            layout_width = "fill",
            layout_height = "wrap",
            padding = "8dp",
            textSize = 14,
        },
        {
            TextView,
            text = "Developed by: Blind Tech Hub Team",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 14,
            padding = "8dp",
        },
        {
            TextView,
            text = "Connect With Us:",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 16,
            padding = "8dp",
        },
        {
            Button,
            text = "Follow on Telegram",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://t.me/blind_mezab"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "Follow on WhatsApp",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local number = "9118141191"
                local url = "https://wa.me/" .. number
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "Telegram Channels",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                showTelegramChannels()
            end
        },
        {
            Button,
            text = "YouTube Channels",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                showYouTubeChannels()
            end
        },
        {
            Button,
            text = "WhatsApp Communities",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                showWhatsAppChannels()
            end
        }
    }
    aboutDlg = LuaDialog(this)
    aboutDlg.View = loadlayout(aboutLayout)
    aboutDlg.setTitle("About")
    aboutDlg.setButton("Close", nil)
    aboutDlg.show()
end

-- Function to show Telegram channels
function showTelegramChannels()
    local telegramLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "Our Telegram Channels",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
            padding = "8dp",
        },
        {
            Button,
            text = "Blind Tech Hub Main Channel",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://t.me/blindtechhubq7c"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "Official Discussion Group",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://t.me/blindtechhubp2s"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "Non-Copyright Music Channel",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://t.me/Noncopyrightbackgrounmusic"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "Technical Audio Tutorials",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://t.me/+1Aazfn0FJ9oxZWE1"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "SP Tech Hub",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://t.me/S_P_Tech_Hub"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        }
    }
    telegramDlg = LuaDialog(this)
    telegramDlg.View = loadlayout(telegramLayout)
    telegramDlg.setTitle("Telegram Channels")
    telegramDlg.setButton("Close", nil)
    telegramDlg.show()
end

-- Function to show YouTube channels
function showYouTubeChannels()
    local youtubeLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "Our YouTube Channels",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
            padding = "8dp",
        },
        {
            Button,
            text = "Blind Tech Hub YouTube",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://youtube.com/@blindtechhub-p2s?si=9I8g9mvMzgc9S9ez"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        }
    }
    youtubeDlg = LuaDialog(this)
    youtubeDlg.View = loadlayout(youtubeLayout)
    youtubeDlg.setTitle("YouTube Channels")
    youtubeDlg.setButton("Close", nil)
    youtubeDlg.show()
end

-- Function to show WhatsApp channels
function showWhatsAppChannels()
    local whatsappLayout = {
        LinearLayout,
        orientation = "vertical",
        layout_width = "fill",
        layout_height = "fill",
        padding = "16dp",
        {
            TextView,
            text = "Our WhatsApp Communities",
            layout_width = "fill",
            layout_height = "wrap",
            gravity = "center",
            textSize = 20,
            padding = "8dp",
        },
        {
            Button,
            text = "World of VI WhatsApp Community",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://chat.whatsapp.com/Kb3QOapabwZGOgzzO8FZof"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        },
        {
            Button,
            text = "Blind Tech Hub WhatsApp Channel",
            layout_width = "fill",
            layout_height = "wrap",
            onClick = function()
                local url = "https://whatsapp.com/channel/0029VbAVDj23AzNYccK2KR3T"
                local intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse(url))
                this.startActivity(intent)
            end
        }
    }
    whatsappDlg = LuaDialog(this)
    whatsappDlg.View = loadlayout(whatsappLayout)
    whatsappDlg.setTitle("WhatsApp Communities")
    whatsappDlg.setButton("Close", nil)
    whatsappDlg.show()
end