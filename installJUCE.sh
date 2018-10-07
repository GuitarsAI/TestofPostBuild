#!/bin/bash

## Installer for JUCE (https://www.juce.com/)
read -p "Install Juce Grapefruit? [Y/n]: " inst
if [ "$inst" = "y" ] || [ "$inst" = "Y" ]
then
    cd ~ 
    if [ -e "JUCE/Projects" ]
    then
        mv JUCE/Projects/ /tmp/tmpJUCEProjects/
    fi
    if [ -e "JUCE" ]
    then
        rm -rf JUCE
    fi

    ## https://forum.juce.com/t/freeze-when-opening-filechooser/16026/38
    echo "Cloning Juce Grapefruit (developer) ..."
    git clone -b develop https://github.com/julianstorer/JUCE

    ## Install dependencies for Juce: (https://forum.juce.com/t/juce-4-2-1-setup-on-apt-based-linux-ubuntu-16-04-lts-mint-elementary-os-freya/17164)
    sudo apt-get -q update
    sudo apt-get -y --force-yes install llvm clang libfreetype6-dev libx11-dev libxinerama-dev libxrandr-dev libxcursor-dev mesa-common-dev libasound2-dev freeglut3-dev libxcomposite-dev libcurl4-gnutls-dev
    
    ## change the default compiler path
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++

    ## Create a 'Projects' folder or put the old one back
    if [ -e "/tmp/tmpJUCEProjects" ]
    then
        mv /tmp/tmpJUCEProjects/ JUCE/Projects/
    else
        mkdir JUCE/Projects
    fi

    ## Build the Projucer from Source code
    cd JUCE/extras/Projucer/Builds/LinuxMakefile
    make CONFIG=Release

    if [ ! $? -eq 0 ]
    then
        echo "Building the Projector failed."
        exit
    fi

    mv build/Projucer ~/JUCE/

    ## Create a Desktop launcher
    sudo touch /usr/share/applications/projucer.desktop
    echo "[Desktop Entry]
Name=Projucer
Comment=Juce Grapefruit Projucer
Exec=/home/$USER/JUCE/Projucer
Icon=/home/$USER/JUCE/extras/Projucer/Source/BinaryData/juce_icon.png
Terminal=false
Type=Application
Categories=AudioVideo;Audio;Graphics;Development;IDE;ProjectManagement;" | sudo tee /usr/share/applications/projucer.desktop
    sudo chmod a+x /usr/share/applications/projucer.desktop

    ## Add the MIME type to the system, so .jucer files will automatically open with the Projucer
    sudo touch /usr/share/mime/packages/juce.xml
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <mime-info xmlns=\"http://www.freedesktop.org/standards/shared-mime-info\">
        <mime-type type=\"application/x-juce\">
            <comment>JUCE project</comment>
            <sub-class-of type=\"application/xml\"/>
            <glob pattern=\"*.jucer\"/>
        </mime-type>
    </mime-info>" | sudo tee /usr/share/mime/packages/juce.xml
    sudo update-mime-database /usr/share/mime
    echo "application/x-juce=projucer.desktop" | sudo tee --append /usr/share/applications/defaults.list
    echo "Installed"
fi
## Steinberg VST SDK 3
read -p "Download Steinberg VST SDK 3? [Y/n]: " inst
if [ "$inst" = "y" ] || [ "$inst" = "Y" ]
then
    cd /tmp/
    if [ -e vstsdk365_12_11_2015_build_67.zip ]
    then
        rm vstsdk365_12_11_2015_build_67.zip
    fi
    echo "Downloading Steinberg VST3 SDK ..."
    wget http://www.steinberg.net/sdk_downloads/vstsdk365_12_11_2015_build_67.zip
    echo "Extracting ..."
    unzip -q vstsdk365_12_11_2015_build_67.zip
    if [ ! -e "/home/$USER/SDKs" ]
    then
        mkdir "/home/$USER/SDKs"
    fi
    if [ -e "/home/$USER/SDKs/VST3 SDK" ]
    then
        rm -r "/home/$USER/SDKs/VST3 SDK"
    fi
    mv "VST3 SDK/" "/home/$USER/SDKs"

    echo "Downloaded."
fi
read -p "Run Projucer? [Y/n]: " inst
if [ "$inst" = "y" ] || [ "$inst" = "Y" ]
then
    /home/$USER/JUCE/Projucer
fi
