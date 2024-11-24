import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.UserProfile;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;
using Toybox.FitContributor as Fit;

class HBDView extends WatchUi.SimpleDataField {

    var HbdField = null;
    hidden var mValue;
    hidden var mRHR as Numeric;
    var use_rhr;

    const HBD_FIELD_ID = 0;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "HBD";
        mValue = 0.0f;
        mRHR = 0;
        use_rhr = Properties.getValue("boolean_prop");
        if (use_rhr) {
            var profile = UserProfile.getProfile();
            mRHR = profile.restingHeartRate;
        }

        // Create the custom FIT data field we want to record.
        HbdField = createField(
            "HBD",
            HBD_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"m"}
        );

        HbdField.setData(0.0);
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
                var delta = (info.currentHeartRate as Number) - mRHR;
                var v = 60*(info.currentSpeed as Float);
                if (delta > 0.0)
                {
                    mValue = v/delta;
                }
            }
        }

        HbdField.setData(mValue);
        return mValue;
    }
}