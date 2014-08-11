module.exports = (grunt) ->
  
  # load all grunt tasks
  pkg: grunt.file.readJSON('package.json'),
  
  # Project configuration.
  grunt.initConfig
    handlebars:
      compile:
        options:
          namespace: "templates"
          processName: (filePath) -> # input:  templates/_header.hbs
            p = filePath.split("/")
            s = p[p.length - 1]
            s.substr 0, s.length - 4 # output: _header

        files:
          "js/templates.js": "templates/*.hbs"

    concat:
      options:
        separator: ";"

      dist:
        src: ["js/handlebars.min.js", "js/tagrid.js"]
        dest: "js/main.js"

    coffee:
      compile:
        files:
          "js/tagrid.js": "coffee/**/*.coffee"
        options:
          sourceMap: true

      tasks: ["concat:dist"]

    sass:
      dist:
        files:
          "css/tagrid.css": "scss/tagrid.scss"
        options:
          style: "compressed"
          sourcemap: true

    watch:
      livereload:
        files: ["index.html", "js/tagrid.js", "js/templates.js"]
        options:
          livereload: true
          spawn: false

      coffee:
        files: "coffee/**/*.coffee"
        tasks: ["coffee"]

      sass:
        files: "scss/**/*.scss"
        tasks: ["sass:dist"]

      css: 
        files: "css/tagrid.css"
        options:
          livereload: true
          spawn: false

      handlebars:
        files: "templates/*.hbs"
        tasks: ["handlebars:compile"]

    
    # css: {
    # 	files: ['css/*.css']
    # }
    connect:
      server:
        options:
          base: ""
          hostname: '*'
          port: 1337

    open:
      server:
        path: "http://localhost:<%= connect.server.options.port %>/"

  grunt.loadNpmTasks "grunt-sass"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-handlebars"
  grunt.loadNpmTasks "grunt-open"
  grunt.registerTask "server", ["connect:server", "open:server", "watch"]
  
  # Default task.
  grunt.registerTask "default", ["server"]