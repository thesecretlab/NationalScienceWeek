package au.net.scienceweek.scienceweek.network;

import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;

import java.net.URL;

@Root(strict = false)
public class Event {

    @Override
    public String toString() {
        return EventName;
    }

    @Element(required = false)
	public String EventID;

    @Element(required = false)
	public String EventName;

    @Element(required = false)
	String EventType;

    /*@ElementList(inline=true)
    List<String> EventCategory;*/

    @Element(required = false)
    String EventStart;

    @Element(required = false)
	String EventEnd;

    @Element(required = false)
	public String EventDescription;

    @Element(required = false)
	String EventTargetAudience;

    @Element(required = false)
	String EventPayment;

    @Element(required = false)
	boolean EventIsFree;

    @Element(required = false)
	String EventContactName;

    @Element(required = false)
	String EventContactOrganisation;

    @Element(required = false)
	String EventContactTelephone;

    @Element(required = false)
	String EventContactEmail;

    @Element(required = false)
	URL EventWebsite;

    @Element(required = false)
	String EventState;

    @Element(required = false)
	String EventMoreInfo;

    @Element(required = false)
    URL EventOfficialImageUrl;

    @Element(required=false)
    Venue Venue;
  
}

