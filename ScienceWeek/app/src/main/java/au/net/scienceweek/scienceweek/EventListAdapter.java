package au.net.scienceweek.scienceweek;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;


import java.util.List;

import au.net.scienceweek.scienceweek.network.Event;

/**
 * Created by desplesda on 25/06/15.
 */
public class EventListAdapter extends ArrayAdapter<Event> {

    LayoutInflater inflater;

    public EventListAdapter(Context context, List<Event> objects) {
        super(context, R.layout.event_list_item, objects);
        inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {


        View vi=convertView;
        if(convertView==null)
            vi = inflater.inflate(R.layout.event_list_item, null);

        TextView eventTitle = (TextView) vi.findViewById(R.id.eventListTitle);
        TextView eventDate= (TextView) vi.findViewById(R.id.eventListDate);

        Event e = getItem(position);

        eventTitle.setText(e.EventName);
        eventDate.setText(e.getStartToFinishString());

        return vi;
    }
}
