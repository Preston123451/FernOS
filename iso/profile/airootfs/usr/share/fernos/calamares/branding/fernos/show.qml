/* FernOS installer slideshow: plain text slides, no external images. */
import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 15000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    component FernSlide: Slide {
        property string title
        property string body
        Rectangle {
            anchors.fill: parent
            color: "#18271F"
            Column {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 18
                Image {
                    source: "logo.png"
                    width: 96; height: 96
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: title
                    color: "#EDE8D8"
                    font.pixelSize: 30; font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Text {
                    text: body
                    color: "#B8B9A5"
                    font.pixelSize: 17
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    FernSlide {
        title: "Welcome to FernOS"
        body: "A calm, fast desktop for coding, working and gaming, built on Arch Linux, CachyOS and KDE Plasma."
    }
    FernSlide {
        title: "🎮 Game Mode"
        body: "One click on the FernOS Modes button in the panel: performance CPU, Feral GameMode, effects off and a night theme. Steam, Lutris, Heroic, Discord and MangoHud are ready to go."
    }
    FernSlide {
        title: "💼 Work Mode"
        body: "A calm theme, a quiet CPU and a 25/5 focus timer. Switch back to Normal any time and your own look comes back."
    }
    FernSlide {
        title: "Ready to code"
        body: "VS Code (Code-OSS), Claude Code, git, Python, Rust, Node.js and C/C++ compilers are installed. Konsole uses the fish shell."
    }
    FernSlide {
        title: "Your apps, your way"
        body: "Zen Browser for the web, Shelly for installing software, and Fern and Fernblox from the Fern family."
    }
}
