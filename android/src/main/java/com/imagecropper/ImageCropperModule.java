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
    private Promise mPromise;
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

    public ImageCropperModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mReactContext = reactContext;
        reactContext.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "ImageCropper";
    }

    @ReactMethod
    public void open(String uriString, Double width, Double height, Promise promise) {
        mPromise = promise;
        UCrop.Options options = new UCrop.Options();
        Uri uri = Uri.parse(uriString);
        Activity activity = getCurrentActivity();
        if (activity == null) {
            promise.reject("error", "Cannot find activity");
            return;
        }

        UCrop.of(uri, Uri.fromFile(new File(mReactContext.getCacheDir(), UUID.randomUUID().toString() + ".jpg")))
                .withAspectRatio(width.floatValue(), height.floatValue())
                .withOptions(options)
                .start(activity);
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mPromise != null) {
            response = Arguments.createMap();
            if (resultCode == Activity.RESULT_OK && requestCode == UCrop.REQUEST_CROP) {
                final Uri resultUri = UCrop.getOutput(data);
                response.putString("uri", resultUri.toString());
                mPromise.resolve(response);
            } else if (resultCode == UCrop.RESULT_ERROR) {
                mPromise.reject("error", UCrop.getError(data));
            }
        }
    }
}
