elifePipeline {
    node('containers-jenkins-plugin') {
        def commit
        def baseGrobidTag

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
                def image = DockerImage.elifesciences(this, 'sciencebeam-grobid-biorxiv', commit)
                def unstable_image = image.addSuffixAndTag('_unstable', commit)
                unstable_image.push()
                unstable_image.tag('latest').push()
            }
       }

       elifeTagOnly { tagName ->
            def releaseVersion = tagName - "v"

            stage 'Push release image', {
                def image = DockerImage.elifesciences(this, 'sciencebeam-grobid-biorxiv', commit)
                image.tag(releaseVersion).push()
                image.tag('latest').push()
            }
        }
    }
}
