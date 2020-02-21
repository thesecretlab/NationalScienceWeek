package au.net.scienceweek.scienceweek.network;

import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.ElementList;
import org.simpleframework.xml.Namespace;
import org.simpleframework.xml.Root;

import java.util.List;

@Root
@Namespace(prefix="xsi", reference="http://www.w3.org/2001/XMLSchema-instance")
public class Events {
    @ElementList(inline = true, entry="Event")
    public List<Event> events;

    @Attribute
    private String schemaLocation;
}

