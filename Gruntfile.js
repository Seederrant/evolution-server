module.exports = function( grunt ) {

    grunt.initConfig( {
            // running `grunt watch` will watch for changes
            watch:     {
                coffee: {
                    files:   [ "coffee/*.coffee", "../evolution/**/*.coffee" ],
                    tasks:   [ "coffee:compile", "coffee:compileClient", "copy:evolutionCommons" ],
                    options: {
                        spawn: false
                    }
                }

            },

            copy:       {
                evolutionCommons:   {
                    files: [
                        // includes files within path
                        {
                            expand: true,
                            cwd:    './js',
                            src:    [ 'EvolutionCommons.js' ],
                            dest:   '../evolution/js/'
                        },

                    ]
                },
            },

            coffee: {
                compile: {
                    expand: true,
                    flatten: true,
                    cwd: 'coffee/',
                    src: ['*.coffee'],
                    dest: 'js/',
                    ext: '.js'
                },
                compileClient: {
                    expand: true,
                    flatten: true,
                    cwd: '../evolution/coffee/',
                    src: ['*.coffee'],
                    dest: '../evolution/js/',
                    ext: '.js'
                }
            }

        }
    );

    // grunt.loadNpmTasks( 'grunt-contrib-less' );
//grunt.loadNpmTasks('grunt-contrib-uglify');
    // grunt.loadNpmTasks( 'grunt-contrib-requirejs' );
    grunt.loadNpmTasks( 'grunt-contrib-watch' );
    // grunt.loadNpmTasks( 'grunt-contrib-compress' );
    grunt.loadNpmTasks( 'grunt-contrib-copy' );
    grunt.loadNpmTasks( 'grunt-contrib-coffee' );
    // grunt.loadNpmTasks( 'grunt-contrib-clean' );
    // grunt.loadNpmTasks( 'grunt-node-webkit-builder' );
    // grunt.loadNpmTasks( 'grunt-exec' );
    // grunt.loadNpmTasks( 'winresourcer' );

    // grunt.registerTask( 'launch-dev', [ 'watch:copyEvolutionCommons', 'watch:coffee'] )
    // grunt.registerTask( 'build', [ 'clean:build', 'less', 'copy:build', 'requirejs', 'compress' ] );
    // grunt.registerTask( 'app-desktop', [ 'clean:desktop', 'nodewebkit', "copy:win64", "copy:win32", "winresourcer:win64ico", "winresourcer:win32ico" ] );
    // grunt.registerTask( 'app-cocoon', [ 'clean:cocoon', 'copy:cocoon', 'exec:cocoon' ] );
    // grunt.registerTask( 'app', [ 'app-desktop', 'app-cocoon' ] );

}
;
