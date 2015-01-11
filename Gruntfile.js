/* global module:false */
module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({
        // Metadata.
        meta: {
            version: '0.1.0'
        },
        banner: '/*! MrUploader - v<%= meta.version %> - ' +
            '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
            '* http://github.com/vinelab/mr-uploader\n' +
            '* Copyright (c) <%= grunt.template.today("yyyy") %> ' +
            'Vinelab; Licensed MIT */\n'
    });

    // Task configuration.
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.config('concat', {
        options: {
            banner: '<%= banner %>',
            stripBanners: true
        },
        dist: {
            src: ['vendors/jquery.Jcrop.min.js', 'dist/mr-uploader.js'],
            dest: 'dist/js/mr-uploader.all.js'
        },
        css: {
            src: ['src/style.css', 'vendors/jquery.Jcrop.min.css'],
            dest: 'dist/css/mr-uploader.css'
        }
    });

    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.config('uglify', {
        options: {
            banner: '<%= banner %>',
            mangle: false
        },
        all: {
            src: '<%= concat.dist.dest %>',
            dest: 'dist/js/mr-uploader.all.min.js'
        }
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.config('coffee', {
        compile: {
            options: {bare: true},
            files: {'dist/js/mr-uploader.js': 'src/uploader.coffee'}
        }
    });

    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.config('cssmin', {
        style: {
            files: [{
                expand: true,
                cwd: 'dist/css',
                src: ['*.css'],
                dest: 'dist/css',
                ext: '.min.css'
            }]
        }
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.config('watch', {
        coffee: {
            files: ['src/**/*'],
            tasks: ['coffee', 'concat', 'uglify', 'cssmin']
        }
    });

};
