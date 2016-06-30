package com.imagecropper;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.yalantis.ucrop.UCrop;

import java.io.File;
import java.util.UUID;

/**
 * Created by witzhsiao on 6/28/16.
 */
public class ImageCropperModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    private Callback mCallback;
    private Activity mActivity;
    private ReactApplicationContext mReactContext;
    WritableMap response;

    private static final String E_USER_CANCEL="E_USER_CANCEL";
    private static final String E_NO_IMAGE_DATA_FOUND = "E_NO_IMAGE_DATA_FOUND";

//    @Override
//    public Map<String, Object> getConstants() {
//        final Map<String, Object> constants = new HashMap<>();
//        constants.put(DURATION_SHORT_KEY, Toast.LENGTH_SHORT);
//        constants.put(DURATION_LONG_KEY, Toast.LENGTH_LONG);
//        return constants;
//    }

    public ImageCropperModule(ReactApplicationContext reactContext, Activity activity) {
        super(reactContext);
        mActivity = activity;
        mReactContext = reactContext;
        reactContext.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "ImageCropper";
    }

    @ReactMethod
    public void open(String uriString, Double width, Double height, Callback callback) {
        mCallback = callback;
        UCrop.Options options = new UCrop.Options();
        Uri uri = Uri.parse(uriString);

        UCrop.of(uri, Uri.fromFile(new File(mReactContext.getCacheDir(), UUID.randomUUID().toString() + ".jpg")))
                .withAspectRatio(width.floatValue(), height.floatValue())
                .withOptions(options)
                .start(mActivity);
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mCallback != null) {
            response = Arguments.createMap();
            if (resultCode != Activity.RESULT_OK) {
                response.putBoolean("success", false);
                response.putString("code", E_USER_CANCEL);
                mCallback.invoke(response);
            } else {
                final Uri resultUri = UCrop.getOutput(data);
                if (resultUri != null) {
                    response.putBoolean("success", true);
                    response.putString("uri", resultUri.toString());
                    mCallback.invoke(response);
                } else {
                    response.putBoolean("success", true);
                    response.putString("code", E_NO_IMAGE_DATA_FOUND);
                }
            }
        }
    }
}
