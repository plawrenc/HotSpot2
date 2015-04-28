<script src="http://maps.google.com/maps/api/js?sensor=false" type="text/javascript"></script>  
<div id="map" style="width: 500px; height: 400px;"></div>  
<script type="text/javascript">  
  var locations = [
    ['Bondi Beach', -33.890542, 151.274856, 1],
    ['Coogee Beach', -33.923036, 151.259052, 2]
  ];
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 10,
    center: new google.maps.LatLng(-33.92, 151.25),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
  var infowindow = new google.maps.InfoWindow();
  var marker, i;
  for (i = 0; i < locations.length; i++) {  
    marker = new google.maps.Marker({
      position: new google.maps.LatLng(locations[i][1], locations[i][2]),
      map: map
    });
  google.maps.event.addListener(marker, 'click', (function(marker, i) {
      return function() {
        infowindow.setContent(locations[i][0]);
        infowindow.open(map, marker);
      }
    })(marker, i));
  }
</script>