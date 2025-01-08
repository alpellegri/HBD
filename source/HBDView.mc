import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.UserProfile;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;
using Toybox.FitContributor as Fit;
// using Toybox.System as Sys;

class HBDView extends WatchUi.SimpleDataField {

    hidden var HbdFieldPlot = null;
    hidden var HbdFieldStat = null;
    hidden var mRHR as Number;
    hidden var use_rhr;
    hidden var use_power;

    const HBD_FIELD_PLOT_ID = 0;
    const HBD_FIELD_STAT_ID = 1;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        // label = (Application.loadResource(Rez.Strings[:AppName]) as String);
        label = "HBD";

        mRHR = 0;
        use_rhr = Properties.getValue("boolean_prop_use_rhr");
        if (use_rhr == true) {
            var profile = UserProfile.getProfile();
            mRHR = profile.restingHeartRate;
        }

        use_power = Properties.getValue("boolean_prop_use_power");

        // Create the custom FIT data field we want to record.
        HbdFieldPlot = createField(
            "HBD",
            HBD_FIELD_PLOT_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"m/b"}
        );
        HbdFieldPlot.setData(0.0);

        HbdFieldStat = createField(
            "HBD",
            HBD_FIELD_STAT_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType=>Fit.MESG_TYPE_SESSION, :units=>"m/b"}
        );
        HbdFieldStat.setData(0.0);
    }

    function calculateValue(heartRate as Number, speed as Float, power as Number) as Float {
        var out = 0.0;
        if (heartRate != null && speed != null && power != null) {
            var value = (use_power == true) ? power : speed;
            var delta = heartRate - mRHR;
            var v = 60 * value;
            if (delta > 0.0) {
                out = v / delta;
            }
        }
        return out;
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {

        var statValue = calculateValue(info.averageHeartRate, info.averageSpeed, info.averagePower);
        HbdFieldStat.setData(statValue);

        var plotValue = calculateValue(info.currentHeartRate, info.currentSpeed, info.currentPower);
        HbdFieldPlot.setData(plotValue);

        return plotValue;
    }
}