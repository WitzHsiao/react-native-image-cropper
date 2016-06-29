package com.imagecropper;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
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
    private Promise mCropperPromise;
    private Activity activity;
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

    public ImageCropperModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "ImageCropper";
    }

    @ReactMethod
    public void open(String uriString, Double width, Double height, final Promise promise) {
        mCropperPromise = promise;
        UCrop.Options options = new UCrop.Options();
        activity = getCurrentActivity();
        Uri uri = Uri.parse(uriString);

        UCrop.of(uri, Uri.fromFile(new File(activity.getCacheDir(), UUID.randomUUID().toString() + ".jpg")))
                .withAspectRatio(width.floatValue(), height.floatValue())
                .withOptions(options)
                .start(activity);
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        response = Arguments.createMap();
        // user cancel
        if (resultCode != Activity.RESULT_OK) {
            mCropperPromise.reject(E_USER_CANCEL, "User cancelled");
        }

        if (resultCode == Activity.RESULT_OK && requestCode == UCrop.REQUEST_CROP) {
            final Uri resultUri = UCrop.getOutput(data);
            if (resultUri != null) {
                response.putString("uri", resultUri.toString());
                mCropperPromise.resolve(response);
            } else {
                mCropperPromise.reject(E_NO_IMAGE_DATA_FOUND, "Cannot find image data");
            }
        } else if (resultCode == UCrop.RESULT_ERROR) {
            mCropperPromise.reject(UCrop.getError(data));
        }
    }
}
