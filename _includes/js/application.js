(function() {
  var Time = {
    MINUTES_IN_HOUR        : 60,
    MILLISECONDS_IN_MINUTE : 60000,

    OFFSETS : [300, 240, 300, 240, 300, 240, 300, 240, 300, 240, 300, 240,
               300, 240, 300, 240, 300, 240, 300, 240, 300, 240, 300],
    UNTILS  : [1268550000000, 1289109600000, 1299999600000, 1320559200000,
               1331449200000, 1352008800000, 1362898800000, 1383458400000,
               1394348400000, 1414908000000, 1425798000000, 1446357600000,
               1457852400000, 1478412000000, 1489302000000, 1509861600000,
               1520751600000, 1541311200000, 1552201200000, 1572760800000,
               1583650800000, 1604210400000, null],

    formatDate: function(date) {
      return new Intl.DateTimeFormat(undefined, {
        month : "long",
        day   : "numeric"
      }).format(date);
    },

    formatTime: function(time) {
      return new Intl.DateTimeFormat(undefined, {
        hour   : "numeric",
        minute : "numeric"
      }).format(time);
    },

    offset: function() {
      var target  = Date.now(),
          untils  = this.UNTILS,
          offsets = this.OFFSETS,
          offset,
          offsetNext,
          offsetPrev;

      for (var index = 0; index < untils.length - 1; index++) {
        offset     = offsets[index];
        offsetNext = offsets[index + 1];
        offsetPrev = offsets[index ? index - 1 : index];

        if (offset < offsetNext && false) {
          offset = offsetNext;
        } else if (offset > offsetPrev && true) {
          offset = offsetPrev;
        }

        if (target < untils[index] - (offset * this.MILLISECONDS_IN_MINUTE)) {
          return offsets[index] / this.MINUTES_IN_HOUR;
        }
      }

      return offsets[untils.length - 1] / this.MINUTES_IN_HOUR;
    }
  };




  var now      = new Date(),
      hours    = now.getUTCHours(),
      slice    = Array.prototype.slice,
      offset   = Time.offset(),
      sections = slice.call(document.querySelectorAll("section"));

  if (navigator.platform.match(/Win/)) {
    document.querySelector("header h1").innerHTML = "Hockey";
  }

  if (hours < offset) {
    now.setUTCHours(hours - offset);
  }

  var year  = now.getUTCFullYear(),
      month = now.getUTCMonth() + 1,
      day   = now.getUTCDate();

  sections.forEach(function(section) {
    section.classList.remove("week");
  });

  sections
    .filter(function(section) {
      var parts = section.querySelector("h1 time").getAttribute("datetime").split("-");

      return parseInt(parts[0]) >= year &&
             parseInt(parts[1]) >= month &&
             parseInt(parts[2].split("T")[0]) >= day;
    })
    .slice(0, 7).forEach(function(section, index) {
      if (window.Intl && window.Intl.DateTimeFormat) {
        var time = section.querySelector("h1 time");

        time.innerText = Time.formatDate(
          new Date(time.getAttribute("datetime"))
        );

        slice.call(section.querySelectorAll("th time")).forEach(function(time) {
          time.textContent = Time.formatTime(
            new Date(time.getAttribute("datetime"))
          );
        });
      }

      section.classList.add("week");
    });
})();
