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
    hidden var mRHR as Numeric;
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

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        var plotValue = 0.0;
        var statValue = 0.0;

        if ((info.currentHeartRate != null) &&
            (info.currentSpeed != null) &&
            (info.currentPower != null)) {
            var value = (use_power == true) ? (info.currentPower as Float) : (info.currentSpeed as Float);
            var delta = (info.currentHeartRate as Number) - mRHR;
            var v = 60*value;
            if (delta > 0.0)
            {
                plotValue = v/delta;
            }
        }
        HbdFieldPlot.setData(plotValue);

        if ((info.averageHeartRate != null) &&
            (info.averageSpeed != null) &&
            (info.averagePower != null)) {
            var value = (use_power == true) ? (info.averagePower as Float) : (info.averageSpeed as Float);
            var delta = (info.averageHeartRate as Number) - mRHR;
            var v = 60*value;
            if (delta > 0.0)
            {
                statValue = v/delta;
            }
        }
        HbdFieldStat.setData(statValue);

        return plotValue;
    }
}