package main

import (
	"bufio"
	"fyne.io/fyne"
	"fyne.io/fyne/app"
	"fyne.io/fyne/canvas"
	"fyne.io/fyne/layout"
	"fyne.io/fyne/widget"
	"github.com/bykovme/gotrans"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strings"
)

func errorHandler(err error) {
	if err != nil {
		panic(err)
	}
}

func getGameDir() string {
	exePath, _ := os.Executable()
	exeDir := path.Dir(exePath)
	gameDir := exeDir + "/game"
	return gameDir
}

func readSettingsCfg(path string) []string {
	var settings []string
	file, err := os.Open(path)
	errorHandler(err)
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		settings = append(settings, scanner.Text())
	}
	return settings
}

func writeSettingCfg(text string, line int) {
	gameDir := getGameDir()
	assetsDir := gameDir + "/assets"
	settingsCfg := assetsDir + "/settings.cfg"
	settings := readSettingsCfg(settingsCfg)
	settings[line] = text
	file, err := os.Create(settingsCfg)
	errorHandler(err)
	defer file.Close()
	for _, line := range settings {
		_, err = io.WriteString(file, line+"\n")
		errorHandler(err)
	}
	file.Sync()
}

func cbRadioFullscreen(text string) {
	value := "0"
	if text == "on" {
		value = "1"
	}
	writeSettingCfg(value, 0)
}

func cbSelectLang(text string) {
	writeSettingCfg(text, 7)
}

func main() {
	err := gotrans.InitLocales("locale")
	errorHandler(err)
	env_lang, _ := os.LookupEnv("LANG")
	lang := strings.Split(env_lang, "_")[0]
	tr_english := gotrans.Tr(lang, "english")
	tr_language := gotrans.Tr(lang, "language")
	tr_fullscreen := gotrans.Tr(lang, "fullscreen")
	tr_on := gotrans.Tr(lang, "on")
	tr_off := gotrans.Tr(lang, "off")
	tr_launch := gotrans.Tr(lang, "launch")

	trans := []string{tr_english}
	gameDir := getGameDir()
	assetsDir := gameDir + "/assets"
	transDir := assetsDir + "/translations"
	settings := readSettingsCfg(assetsDir + "/settings.cfg")
	fullscreen, language := settings[0], settings[len(settings)-1]

	transList, _ := ioutil.ReadDir(transDir)
	for _, file := range transList {
		trans = append(trans, file.Name())
	}

	app := app.New()
	window := app.NewWindow("SpelunkyClassicHDLauncher")
	window.SetFixedSize(true)
	file, err := os.Open(assetsDir + "/icon.png")
	errorHandler(err)
	defer file.Close()
	iconData, err := ioutil.ReadAll(file)
	errorHandler(err)
	iconRecource := fyne.NewStaticResource("icon", iconData)
	window.SetIcon(iconRecource)

	exePath, _ := os.Executable()
	exeDir := path.Dir(exePath)
	image := canvas.NewImageFromFile(exeDir + "/launcher.jpg")
	image.SetMinSize(fyne.NewSize(518, 240))

	labelLang := widget.NewLabel(tr_language)
	spacer0 := layout.NewSpacer()
	selectLang := widget.NewSelect(trans, cbSelectLang)
	selectLang.SetSelected(language)
	hbox0 := widget.NewHBox(labelLang, spacer0, selectLang)

	labelFullscreen := widget.NewLabel(tr_fullscreen)
	spacer1 := layout.NewSpacer()
	radioFullscreen := widget.NewRadio([]string{tr_on, tr_off}, cbRadioFullscreen)
	radioFullscreen.Horizontal = true
	if fullscreen == "1" {
		radioFullscreen.SetSelected(tr_on)
	} else {
		radioFullscreen.SetSelected(tr_off)
	}
	hbox1 := widget.NewHBox(labelFullscreen, spacer1, radioFullscreen)

	buttonLaunch := widget.NewButton(
		tr_launch,
		func() {
			cmd := exec.Command(gameDir + "/spelunky")
			cmd.Start()
			os.Exit(0)
		},
	)

	window.SetContent(
		widget.NewVBox(
			image,
			hbox0,
			hbox1,
			buttonLaunch,
		),
	)

	window.ShowAndRun()
}
