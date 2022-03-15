fx_version 'cerulean'

game 'gta5'


author 'Ewony#2235'

ui_page('html/index.html') 

client_scripts {
    'cl_main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js'
}

exports {
    'Progress',
    'ProgressWithStartEvent',
    'ProgressWithTickEvent',
    'ProgressWithStartAndTick'
}