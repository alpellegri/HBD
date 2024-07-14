import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.UserProfile;
using Toybox.System;

class HBDView extends WatchUi.SimpleDataField {

    hidden var mValue;
    hidden var mRHR as Numeric;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        var profile = UserProfile.getProfile();
        mRHR = profile.restingHeartRate;
        label = "HBD";
        mValue = 0.0f;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        mValue = 0.0;
        if ((info has :currentHeartRate) && (info has :currentSpeed)) {
            if ((info.currentHeartRate != null) && (info.currentSpeed != null)) {
                var delta = (info.currentHeartRate as Number);
                // System.println("currentSpeed: " + info.currentSpeed);
                var vo2 = 60 * (info.currentSpeed as Float);
                // System.println("vo2: " + vo2);
                if (delta > 0.0)
                {
                    mValue = vo2/delta;
                }
            }
        }
        return mValue;
    }
}