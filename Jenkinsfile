pipeline {
    agent any

    stages {
        stage('Build Backend') {
            steps {
                dir('back') {
                    bat 'mvnw clean package -DskipTests'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('front') {
                    bat 'npm install'
                    bat 'npm run build'
                }
            }
        }

        stage('Build and Run Docker') {
            steps {
                bat 'docker-compose build'
                bat 'docker-compose up -d'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(
                    credentialsId: 'tomcat-credentials',
                    path: '',
                    url: 'http://localhost:8080'
                )],
                contextPath: '/rhythm',
                war: 'back/target/*.war'
            }
        }
    }
}