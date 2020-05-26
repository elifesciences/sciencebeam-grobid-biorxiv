elifePipeline {
    node('containers-jenkins-plugin') {
        def commit

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }

        stage 'Build and run tests', {
            try {
                sh "make IMAGE_TAG=${commit} ci-build-and-test"
            } finally {
                sh "make ci-clean"
            }
        }

        elifeMainlineOnly {
            stage 'Merge to master', {
                elifeGitMoveToBranch commit, 'master'
            }

            stage 'Push unstable image', {
                try {
                    sh "make IMAGE_TAG=${commit} ci-push-unstable-images"
                } finally {
                    sh "make ci-clean"
                }
            }
       }

       elifeTagOnly { tagName ->
            def releaseVersion = tagName - "v"

            stage 'Push release image', {
                try {
                    sh "make \
                        IMAGE_TAG=${commit} \
                        NEW_IMAGE_TAG=${releaseVersion} \
                        ci-push-release-images"
                } finally {
                    sh "make ci-clean"
                }
            }
        }
    }
}
