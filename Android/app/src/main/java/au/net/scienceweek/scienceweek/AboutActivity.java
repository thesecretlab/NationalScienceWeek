//  This file is released under the terms of the MIT License.
// Please see LICENSE.md in the root directory.

package au.net.scienceweek.scienceweek;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.WebView;


public class AboutActivity extends ActionBarActivity {

    final String aboutURL = "http://www.scienceweek.secretlab.com.au/scienceweekinfo.html";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);

        WebView webView = (WebView) findViewById(R.id.webView);

        webView.loadUrl(aboutURL);

    }
}
