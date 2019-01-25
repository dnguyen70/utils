#!/bin/bash -e

CODEDIR=~/devmount/code
GITDIR=~/devmount/tool/git
INTELLIJDIR=~/devmount/tool/intellij
M2DIR=~/devmount/tool/maven
BINDIR=~/devmount/bin
SBTREPOFILE=~/.sbt/repositories
IVYCREDENTIAL=~/.ivy2/.credentials

RallyArtifactAC=${1:-""}

SCALA_V=scala-2.11.11
SBT_V=sbt-0.13.15


echo "Local Development Environment Install Script"
echo
echo "This script can be run repeatedly and keep tools up to date"
echo "Sets up the components necessary to local development including:"
echo "  * brew"
echo "  * brew cask"
echo "  * git"
echo "  * docker for Mac"
echo "  * jenv/java8"
echo "  * scalaenv/scala211"
echo "  * sbtenv/sbt013"
echo "  * postgresql"
echo "  * pgAdmin4"
echo "  * kafka"
echo "  * Kafka Tool"
echo



function installHomeBrew {
    if [[ -f /usr/local/bin/brew ]]
    then
        echo "brew is already installed. Running \"brew update\""
        brew update
    else
        echo "Installing brew."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

function installBrewCask {
    if [[ ! -f /usr/local/bin/brew ]]
    then
        installHomeBrew
    fi

    if [[ -f /usr/local/bin/brew ]]
    then
        echo "adding cask repository"
        brew tap caskroom/cask
    fi
}

function installGit {
    if [[ $(brew list | grep git) ]];then
        if [[ $(brew outdated | grep git) ]];then
            echo "git is outdated. Upgrading"
            brew reinstall git
        else
            echo "git is up to date"
        fi
    else
        echo "No git found. Installing..."
        brew install git
    fi
}

function installJava8 {
    if [[ $(brew cask list | grep java8) ]];then
        if [[ $(brew cask outdated | grep java8) ]];then
            echo "java8 is outdated. Upgrading"
            reInstallJava8
        else
            echo "java8 is up to date"
        fi
    else
        echo "No java8 found. Installing..."
        reInstallJava8
    fi
}

function reInstallJava8 {
    echo "*** It may ask for password 10 times during installing java8... ***"
    sudo rm -rf /Library/PreferencePanes/JavaControlPanel.prefPane /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin /Library/LaunchAgents/com.oracle.java.Java-Updater.plist /Library/PrivilegedHelperTools/com.oracle.java.JavaUpdateHelper /Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist /Library/Preferences/com.oracle.java.Helper-Tool.plist
    brew cask --force install caskroom/versions/java8 --debug
}

function installJenv {

    sed -i.bak '/export JENV_ROOT/d' ~/.bash_profile
    sed -i.bak '/eval "$(jenv/d' ~/.bash_profile
    echo 'export JENV_ROOT=/usr/local/opt/jenv' >> ~/.bash_profile
    echo 'eval "$(jenv init -)"' >> ~/.bash_profile

    sed -i.bak '/export JENV_ROOT/d' ~/.zshrc
    sed -i.bak '/eval "$(jenv/d' ~/.zshrc
    echo 'export JENV_ROOT=/usr/local/opt/jenv' >> ~/.zshrc
    echo 'eval "$(jenv init -)"' >> ~/.zshrc


    if [[ $(brew list | grep jenv) ]];then
        echo "jenv already installed. Checking if it is outdated"
        if [[ $(brew outdated | grep jenv) ]];then
            echo "jenv is outdated. Upgrading"
            brew upgrade jenv
            addJava8ToJENV
        else
            addJava8ToJENV
            echo "jenv is up to date"
        fi
    else
        echo "No jenv found. Installing..."
        brew install jenv

        addJava8ToJENV
    fi
}

function installScala211 {
    if [[ $(brew list | grep scala@2.11) ]];then
        if [[ $(brew outdated | grep scala@2.11) ]];then
            echo "scala@2.11 is outdated. Upgrading"
            brew reinstall scala@2.11
        else
            echo "scala@2.11 is up to date"
        fi
    else
        echo "No scala@2.11 found. Installing..."
        brew install scala@2.11
    fi
}

function installScalaenv {
    sed -i.bak '/export SCALAENV_ROOT/d' ~/.bash_profile
    sed -i.bak '/eval "$(scalaenv/d' ~/.bash_profile
    echo 'export SCALAENV_ROOT=/usr/local/opt/scalaenv' >> ~/.bash_profile
    echo 'eval "$(scalaenv init -)"' >> ~/.bash_profile

    sed -i.bak '/export SCALAENV_ROOT/d' ~/.zshrc
    sed -i.bak '/eval "$(scalaenv/d' ~/.zshrc
    echo 'export SCALAENV_ROOT=/usr/local/opt/scalaenv' >> ~/.zshrc
    echo 'eval "$(scalaenv init -)"' >> ~/.zshrc

    if [[ $(brew list | grep scalaenv) ]];then
        echo "scalaenv already installed. Checking if it is outdated"
        if [[ $(brew outdated | grep scalaenv) ]];then
            echo "scalaenv is outdated. Upgrading"
            brew upgrade scalaenv
            source ~/.bash_profile
            addScala211ToScalaENV
        else
            addScala211ToScalaENV
            echo "scalaenv is up to date"
        fi
    else
        echo "No scalaenv found. Installing..."
        brew install scalaenv
        source ~/.bash_profile

        addScala211ToScalaENV
    fi
}

function installSbt013 {
    if [[ $(brew list | grep sbt@0.13) ]];then
        if [[ $(brew outdated | grep sbt@0.13) ]];then
            echo "sbt@0.13 is outdated. Upgrading"
            brew reinstall sbt@0.13
        else
            echo "sbt@0.13 is up to date"
        fi
    else
        echo "No sbt@0.13 found. Installing..."
        brew install sbt@0.13
    fi
}

function installSbtenv {

    # dirty fix zsh bug
    sed -i.bak 's/-ag/-a/g' /usr/local/opt/jenv/plugins/export/etc/jenv.d/init/export_jenv_hook.zsh
    sed -i.bak '/export SBTENV_ROOT/d' ~/.bash_profile
    sed -i.bak '/eval "$(sbtenv/d' ~/.bash_profile
    echo 'export SBTENV_ROOT=/usr/local/opt/sbtenv' >> ~/.bash_profile
    echo 'eval "$(sbtenv init -)"' >> ~/.bash_profile

    sed -i.bak '/export SBTENV_ROOT/d' ~/.zshrc
    sed -i.bak '/eval "$(sbtenv/d' ~/.zshrc
    echo 'export SBTENV_ROOT=/usr/local/opt/sbtenv' >> ~/.zshrc
    echo 'eval "$(sbtenv init -)"' >> ~/.zshrc


    if [[ $(brew list | grep sbtenv) ]];then
        echo "sbtenv already installed. Checking if it is outdated"
        if [[ $(brew outdated | grep sbtenv) ]];then
            echo "sbtenv is outdated. Upgrading"
            brew upgrade sbtenv
            source ~/.bash_profile
            addSbt013ToSbtENV
        else
            addSbt013ToSbtENV
            echo "sbtenv is up to date"
        fi
    else
        echo "No sbtenv found. Installing..."
        brew install sbtenv

        addSbt013ToSbtENV
    fi
}


function installDocker {
    if [[ $(brew cask list | grep docker) ]];then
        echo "docker already installed. Checking if it is outdated"
        if [[ $(checkCaskOutdated docker) ]];then
           echo "docker is outdated. Reinstalling docker"
           reinstallCaskFormular docker Docker Docker
        else
            echo "docker is up to date"
        fi
    else
        echo "No docker found. Installing..."
        brew cask install docker
        open /Applications/Docker.app
    fi
}

function installPostgresql {
    if [[ $(brew list | grep postgresql) ]];then
        if [[ $(brew outdated | grep postgresql) ]];then
            echo "postgresql is outdated. Upgrading"
            brew reinstall postgresql
            brew services start postgresql
        else
            echo "postgresql is up to date"
        fi
    else
        echo "No postgresql found. Installing..."
        brew install postgresql
        brew services start postgresql
    fi
}

function installPgadmin4 {
    if [[ $(brew cask list | grep pgadmin4) ]];then
        echo "pgadmin4 already installed. Checking if it is outdated"
        if [[ $(checkCaskOutdated pgadmin4) ]];then
           echo "pgadmin4 is outdated. Reinstalling pgadmin4"
           reinstallCaskFormular pgadmin4 pgAdmin4 "pgAdmin 4"
        else
            echo "pgadmin4 is up to date"
            openApp pgAdmin4 "pgAdmin 4"
        fi
    else
        echo "No pgadmin4 found. Installing..."
        brew cask install pgadmin4
        open -a "/Applications/pgAdmin 4.app"
    fi
}

function installKafka {
    if [[ $(brew list | grep kafka) ]];then
        if [[ $(brew outdated | grep kafka) ]];then
            echo "kafka is outdated. Upgrading"
            brew reinstall kafka
        else
            echo "kafka is up to date"
        fi
    else
        echo "No kafka found. Installing..."
        brew install kafka
        brew services start zookeeper
        brew services start kafka
    fi
}

function installKitematic {
    if [[ $(brew cask list | grep kitematic) ]];then
        echo "kitematic already installed."
    else
        echo "No kitematic found. Installing..."
        brew cask install kitematic
    fi
}

function installKafkaToll {
    if [[ $(brew cask list | grep kafka-tool) ]];then
        echo "kafka-tool already installed. Checking if it is outdated"
        if [[ $(checkCaskOutdated kafka-tool) ]];then
           echo "kafka-tool is outdated. Reinstalling kafka-tool"
           reinstallCaskFormular kafka-tool JavaApplicationStub "Kafka Tool"
        else
            echo "kafka-tool is up to date"
            openApp JavaApplicationStub "Kafka Tool"
        fi
    else
        echo "No kafka-tool found. Installing..."
        brew cask install kafka-tool
        open -a "/Applications/Kafka Tool.app"
    fi
}

function installXquartz {
    if [[ $(brew cask list | grep xquartz) ]];then
        echo "xquartz already installed."
    else
        echo "No xquartz found. Installing..."
        brew cask install xquartz
        source ~/.bash_profile
    fi
}

function installPre-commit {
    if [[ $(brew list | grep pre-commit) ]];then
        if [[ $(brew outdated | grep pre-commit) ]];then
            echo "pre-commit is outdated. Upgrading"
            brew reinstall pre-commit
        else
            echo "pre-commit is up to date"
        fi
    else
        echo "No pre-commit found. Installing..."
        brew install pre-commit
    fi
}

function installMaestro {
    if [[ $(brew list | grep maestro) ]];then
        if [[ $(brew outdated | grep maestro) ]];then
            echo "maestro is outdated. Upgrading"
            brew update
            brew upgrade maestro
            maestro fetch
        else
            echo "maestro is up to date"
        fi
    else
        echo "No maestro found. Installing..."
        brew services stop --all && brew services list
        brew tap audaxhealthinc/anchor git@github.com:AudaxHealthInc/homebrew-anchor.git
        brew install maestro
        maestro fetch
    fi
}

function checkCaskOutdated {

    formula=$1

    info=$(brew cask info $formula | sed -ne '1,/^From:/p')
    new_ver=$(echo "$info" | head -n 1 | cut -d' ' -f 2)
    cur_vers=$(echo "$info" \
        | grep '^/usr/local/Caskroom' \
        | cut -d' ' -f 1 \
        | cut -d/ -f 6)
    latest_cur_ver=$(echo "$cur_vers" \
        | tail -n 1)
    cur_vers_list=$(echo "$cur_vers" \
        | tr '\n' ' ' | sed -e 's/ /, /g; s/, $//')
    if [ "$new_ver" != "$latest_cur_ver" ]; then
        echo "$formula ($cur_vers_list) < $new_ver"
    fi
}

function reinstallCaskFormular {

  formula=$1
  progress=$2
  app=/Applications/$3.app

  if [[ $(pgrep $progress) ]];then
      kill `pgrep $progress`
  fi

  brew update
  brew cleanup
  rm -rf /usr/local/Caskroom/$formula
  sudo rm -rf "$app"
  brew cask install $formula

  open -a "$app"
}

function openApp {
  progress=$1
  app=/Applications/$2.app

  if [[ ! $(pgrep $progress) ]];then
      open -a "$app"
  fi
}


function addJava8ToJENV() {
    source ~/.bash_profile
    jenv enable-plugin export

    CURRENTVERSION=$(jenv version | awk '{print $1}')

    JAVAVERSION=$(brew cask list --versions java8 | awk '{print $2}' | awk -F'-' '{print $1}')
    JENVJAVA=${JAVAVERSION//_/.}

    if [[ $JENVJAVA != $CURRENTVERSION ]];then
        if [[ -z $(jenv versions | grep $JENVJAVA) ]];then
            echo "adding java to jenv"
            jenv add /Library/Java/JavaVirtualMachines/jdk${JAVAVERSION}.jdk/Contents/Home
        fi

        jenv global ${JENVJAVA}
    fi

}

function addScala211ToScalaENV() {

    source ~/.bash_profile

    CURRENTVERSION=$(scalaenv version | awk '{print $1}')

    SCALAVERSION=$SCALA_V

    if [[ $SCALAVERSION != $CURRENTVERSION ]];then
        if [[ -z $(scalaenv versions | grep $SCALAVERSION) ]];then
            echo "adding scala211 to scalaenv"
            source ~/.bash_profile
            scalaenv install $SCALAVERSION
            scalaenv rehash
        fi

        scalaenv global ${SCALAVERSION}
    fi
}

function addSbt013ToSbtENV() {

    source ~/.bash_profile

    CURRENTVERSION=$(sbtenv version | awk '{print $1}')

    SBTVERSION=$SBT_V

    if [[ $SBTVERSION != $CURRENTVERSION ]];then
        if [[ -z $(sbtenv versions | grep $SBTVERSION) ]];then
            if [[ ! $(brew list | grep gpg$) ]];then
                echo "install gpg dependency for sbtenv"
                brew install gpg
            fi

            echo "adding scala013 to sbtenv"
            source ~/.bash_profile
            sbtenv install $SBTVERSION
            sbtenv rehash
        fi

        sbtenv global ${SBTVERSION}
    fi

}


read -p "Begin? [Y/n] " REPLY
if [[ $REPLY =~ ^[Nn]$ ]]
then
    exit 1
fi

if [[ ! -f ~/.bash_profile ]]
then
    touch ~/.bash_profile
fi

if [[ ! -f ~/.zshrc ]]
then
    touch ~/.zshrc
fi

installHomeBrew
installBrewCask
installGit
installJava8
installJenv
installScalaenv
installSbtenv
installDocker
installPostgresql
installPgadmin4
installKafka
installKafkaToll
installPre-commit
installKitematic
installMaestro
#installXquartz






# This part setup local mount for volumes

if [ ! -d ${CODEDIR} ]; then
    mkdir -p $CODEDIR
fi

if [ ! -d ${GITDIR} ]; then
    mkdir -p $GITDIR/config
    mkdir $GITDIR/projects
    touch ${GITDIR}/config/.gitconfig
    touch ${GITDIR}/config/.git-credentials
fi

if [ ! -d ${INTELLIJDIR} ]; then
    mkdir -p $INTELLIJDIR/config
    mkdir $INTELLIJDIR/projects
fi

if [ ! -d ${M2DIR} ]; then
    mkdir -p $M2DIR/.m2
fi

if [ ! -d ${BINDIR} ]; then
    mkdir -p $BINDIR
fi


myid=$(id -nu)

#if [[ ! -f ${SBTREPOFILE} ]]
#then
#    touch ${SBTREPOFILE}
#fi

#echo "[repositories]" > ${SBTREPOFILE}
#echo "    maven-local" >> ${SBTREPOFILE}
#echo "    cache: file:///Users/${myid}/.ivy2/cache, [organisation]/[module]/ivy-[revision].xml, [organisation]/[module]/[type]s/[module]-[revision].[type]" >> ${SBTREPOFILE}
#echo "    my-maven-proxy-releases: http://repo1.uhc.com/artifactory/repo/" >> ${SBTREPOFILE}
##echo "    typesafe-ivy-releases: https://dl.bintray.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]" >> ${SBTREPOFILE}
##echo "    typesafe-releases: http://dl.bintray.com/typesafe/maven-releases/" >> ${SBTREPOFILE}
##echo "    templemore-repository: http://templemore.co.uk/repo/" >> ${SBTREPOFILE}
#echo "    sbt-plugin-ivy-releases: https://dl.bintray.com/sbt/sbt-plugin-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]" >> ${SBTREPOFILE}
#echo "    sbt-plugin: https://dl.bintray.com/sbt/sbt-plugin-releases/" >> ${SBTREPOFILE}
#echo "    maven-central" >> ${SBTREPOFILE}
#echo "    " >> ${SBTREPOFILE}


if [[ -f ${SBTREPOFILE} ]]
then
    mv ${SBTREPOFILE} ${SBTREPOFILE}.bak
fi

if [[ ! -z ${RallyArtifactAC} ]];then

    if [[ ! -f ${IVYCREDENTIAL} ]]
    then
        mkdir -p ~/.ivy2
        touch ${IVYCREDENTIAL}
    fi

    array=(${RallyArtifactAC//// })

    echo "realm=Artifactory Realm" > ${IVYCREDENTIAL}
    echo "host=artifacts.werally.in" >> ${IVYCREDENTIAL}
    echo "user=${array[0]}" >> ${IVYCREDENTIAL}
    echo "password=${array[1]}" >> ${IVYCREDENTIAL}
    echo "    " >> ${IVYCREDENTIAL}
fi

git config --global url."https://github.com".insteadOf git@github.com
git config --global url."https://".insteadOf git://
