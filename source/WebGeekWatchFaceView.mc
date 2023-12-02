import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

class WebGeekWatchFaceView extends WatchUi.WatchFace {

    // Fonts
    private var fontSmall;
    private var fontMedium;
    private var fontLarge;
    private var fontWeatherIcons;

    // Images
    private var background;

    // Contants
    private var centerX, centerY, screenH, screenW;

    // Icons
    const ICON_HEART = "!";
    const ICON_BLUETOOTH = "$";
    const ICON_NOTIFICATION = "\"";
	const ICON_ALARM = "/";
	const ICON_MOON = "%";

    const ICON_BATTERY_100 = "(";
    const ICON_BATTERY_75 = "*";
    const ICON_BATTERY_50 = "&";
	const ICON_BATTERY_25 = "?";

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // Screen
        screenH = dc.getHeight();
    	screenW = dc.getWidth();
    	centerX = screenW / 2;
    	centerY = screenH / 2;

        // Fonts
        fontMedium = WatchUi.loadResource(Rez.Fonts.FontelloMedium);
        fontLarge = WatchUi.loadResource(Rez.Fonts.FontelloLarge);
        fontWeatherIcons = WatchUi.loadResource(Rez.Fonts.WeatherIcons);

        // Images
        background = WatchUi.loadResource(Rez.Drawables.Background);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear
        dc.clear();

        // Background
        dc.drawBitmap(0, 0, background);

        var lightTextColor = 0xdddddd;
        var darkTextColor = Graphics.COLOR_BLACK;

        var timeY = 125;
        var dateY = 199;

        // Time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);

        dc.setColor(lightTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, timeY, fontLarge, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Month
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        dc.setColor(lightTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(244, dateY, fontMedium, today.month, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Day of month
        dc.setColor(darkTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(318, dateY, fontMedium, today.day, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var dataY = 287;

        // HR Icon
        var heartIconColor = 0xFF0202;
        dc.setColor(heartIconColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(82, dataY, fontMedium, ICON_HEART, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // HR
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr == null) {
            hr = "--";
        }
        dc.setColor(lightTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(118, dataY, fontMedium, hr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Weather
        var weather = Weather.getCurrentConditions();

        var condition = weather != null && weather.condition != null ? weather.condition : Toybox.Weather.CONDITION_CLEAR;
        var temperature = weather != null && weather.temperature != null ? weather.temperature : "--";
        dc.setColor(darkTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(187, dataY, fontWeatherIcons, getWeatherIconCode(condition, clockTime), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(225, dataY, fontMedium, temperature, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Battery
        var sysStats = System.getSystemStats();
        var batteryIcon;
        if (sysStats.battery > 90) {
            batteryIcon = ICON_BATTERY_100;
        } else if (sysStats.battery > 60) {
            batteryIcon = ICON_BATTERY_75;
        } else if (sysStats.battery > 30) {
            batteryIcon = ICON_BATTERY_50;
        } else {
            batteryIcon = ICON_BATTERY_25;
        }

        dc.setColor(darkTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(291, dataY, fontMedium, batteryIcon, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(328, dataY, fontMedium, sysStats.battery.toLong(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Icons
        var iconsString = "";
        var settings = System.getDeviceSettings();
	    if (settings.phoneConnected) {
            iconsString += ICON_BLUETOOTH + " ";
	    }
        if (settings.alarmCount > 0) {
            iconsString += ICON_ALARM + " ";
	    }
        if (settings.doNotDisturb) {
            iconsString += ICON_MOON + " ";
        }
        if (settings.notificationCount > 0) {
            iconsString += ICON_NOTIFICATION + " ";
	    }
        iconsString = iconsString.substring(0, iconsString.length() - 1);
        dc.setColor(lightTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 382, fontMedium, iconsString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    // Code from https://github.com/duchacekjan/jgsface/blob/master/source/JGSCommonModule.mc
    function getWeatherIconCode(condition, clockTime) {
        var isNight = clockTime.hour >= 20 || clockTime.hour < 6;
        var code;
        switch (condition) {
            case Toybox.Weather.CONDITION_CLEAR: {
                code = 'A';
                break;
            }
            case Toybox.Weather.CONDITION_PARTLY_CLOUDY: {
                code = 'B';
                break;
            }
            case Toybox.Weather.CONDITION_MOSTLY_CLOUDY: {
                code = 'C';
                break;
            }
            case Toybox.Weather.CONDITION_RAIN: {
                code = 'D';
                break;
            }
            case Toybox.Weather.CONDITION_SNOW: {
                code = 'E';
                break;
            }
            case Toybox.Weather.CONDITION_WINDY: {
                code = 'F';
                break;
            }
            case Toybox.Weather.CONDITION_THUNDERSTORMS: {
                code = 'G';
                break;
            }
            case Toybox.Weather.CONDITION_WINTRY_MIX: {
                code = 'H';
                break;
            }
            case Toybox.Weather.CONDITION_FOG: {
                code = 'I';
                break;
            }
            case Toybox.Weather.CONDITION_HAZY: {
                code = '@';
                break;
            }
            case Toybox.Weather.CONDITION_HAIL: {
                code = 'J';
                break;
            }
            case Toybox.Weather.CONDITION_SCATTERED_SHOWERS: {
                code = 'K';
                break;
            }
            case Toybox.Weather.CONDITION_SCATTERED_THUNDERSTORMS: {
                code = 'L';
                break;
            }
            case Toybox.Weather.CONDITION_UNKNOWN_PRECIPITATION: {
                code = '?';
                break;
            }
            case Toybox.Weather.CONDITION_LIGHT_RAIN: {
                code = '7';
                break;
            }
            case Toybox.Weather.CONDITION_HEAVY_RAIN: {
                code = '4';
                break;
            }
            case Toybox.Weather.CONDITION_LIGHT_SNOW: {
                code = '6';
                break;
            }
            case Toybox.Weather.CONDITION_HEAVY_SNOW: {
                code = '3';
                break;
            }
            case Toybox.Weather.CONDITION_LIGHT_RAIN_SNOW: {
                code = '5';
                break;
            }
            case Toybox.Weather.CONDITION_HEAVY_RAIN_SNOW: {
                code = '/';
                break;
            }
            case Toybox.Weather.CONDITION_CLOUDY: {
                code = '\\';
                break;
            }
            case Toybox.Weather.CONDITION_RAIN_SNOW: {
                code = '5';
                break;
            }
            case Toybox.Weather.CONDITION_PARTLY_CLEAR: {
                code = 'C';
                break;
            }
            case Toybox.Weather.CONDITION_MOSTLY_CLEAR: {
                code = 'B';
                break;
            }
            case Toybox.Weather.CONDITION_LIGHT_SHOWERS: {
                code = 'K';
                break;
            }
            case Toybox.Weather.CONDITION_SHOWERS: {
                code = 'M';
                break;
            }
            case Toybox.Weather.CONDITION_HEAVY_SHOWERS: {
                code = 'D';
                break;
            }
            case Toybox.Weather.CONDITION_CHANCE_OF_SHOWERS: {
                code = 'K';
                break;
            }
            case Toybox.Weather.CONDITION_CHANCE_OF_THUNDERSTORMS: {
                code = 'L';
                break;
            }
            case Toybox.Weather.CONDITION_MIST: {
                code = '(';
                break;
            }
            case Toybox.Weather.CONDITION_DUST: {
                code = '{';
                break;
            }
            case Toybox.Weather.CONDITION_DRIZZLE: {
                code = '#';
                break;
            }
            case Toybox.Weather.CONDITION_TORNADO: {
                code = '$';
                break;
            }
            case Toybox.Weather.CONDITION_SMOKE: {
                code = '}';
                break;
            }
            case Toybox.Weather.CONDITION_ICE: {
                code = '2';
                break;
            }
            case Toybox.Weather.CONDITION_SAND: {
                code = '{';
                break;
            }
            case Toybox.Weather.CONDITION_SQUALL: {
                code = ']';
                break;
            }
            case Toybox.Weather.CONDITION_SANDSTORM: {
                code = '[';
                break;
            }
            case Toybox.Weather.CONDITION_VOLCANIC_ASH: {
                code = ')';
                break;
            }
            case Toybox.Weather.CONDITION_HAZE: {
                code = '(';
                break;
            }
            case Toybox.Weather.CONDITION_FAIR: {
                code = 'N';
                break;
            }
            case Toybox.Weather.CONDITION_HURRICANE: {
                code = '9';
                break;
            }
            case Toybox.Weather.CONDITION_TROPICAL_STORM: {
                code = '8';
                break;
            }
            case Toybox.Weather.CONDITION_CHANCE_OF_SNOW: {
                code = 'O';
                break;
            }
            case Toybox.Weather.CONDITION_CHANCE_OF_RAIN_SNOW: {
                code = 'H';
                break;
            }
            case Toybox.Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN: {
                code = '7';
                break;
            }
            case Toybox.Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW: {
                code = '6';
                break;
            }
            case Toybox.Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW: {
                code = '5';
                break;
            }
            case Toybox.Weather.CONDITION_FLURRIES: {
                code = '4';
                break;
            }
            case Toybox.Weather.CONDITION_FREEZING_RAIN: {
                code = '3';
                break;
            }
            case Toybox.Weather.CONDITION_SLEET: {
                code = 'P';
                break;
            }
            case Toybox.Weather.CONDITION_ICE_SNOW: {
                code = '2';
                break;
            }
            case Toybox.Weather.CONDITION_THIN_CLOUDS: {
                code = '1';
                break;
            }
            default: {
                code = '0';
                break;
            }
        }

        if (isNight && code >= 'A' && code <= 'Z') {
            code = code.toLower();
        }
        if (code != null) {
            code = code.toString();
        }

        return code;
    }
}
