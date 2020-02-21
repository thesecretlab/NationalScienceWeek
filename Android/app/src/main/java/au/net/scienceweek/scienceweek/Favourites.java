// This file is released under the terms of the MIT License.
// Please see LICENSE.md in the root directory.

package au.net.scienceweek.scienceweek;

import android.content.Context;
import android.content.SharedPreferences;
import android.support.annotation.NonNull;

import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * Created by desplesda on 7/07/15.
 */
public class Favourites {

    static final String prefsTag = "FAVOURITE_EVENTS";

    public static boolean isEventFavourite(Context context, String eventID) {

       SharedPreferences preferences = context.getSharedPreferences(prefsTag, 0);

       return preferences.getBoolean(eventID, false);

    }

    public static void setEventFavourite(Context context, String eventID, boolean isFavourite) {

        SharedPreferences.Editor editor = context.getSharedPreferences(prefsTag, 0).edit();

        editor.putBoolean(eventID, isFavourite);

        editor.commit();

    }


}
