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
        month   : "long",
        day     : "numeric",
        weekday : "long"
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
      empty    = document.querySelector(".empty"),
      hours    = now.getUTCHours(),
      slice    = Array.prototype.slice,
      offset   = Time.offset(),
      sections = slice.call(document.querySelectorAll("section"));

  if (navigator.platform.match(/Win/)) {
    document.querySelector("header h1 a").innerHTML = "Hockey";
  }

  if (hours < offset) {
    now.setUTCHours(hours - offset);
  }

  var year  = now.getUTCFullYear(),
      month = now.getUTCMonth() + 1,
      day   = now.getUTCDate(),
      limit = 7,
      count = 1;

  sections.forEach(function(section) {
    section.classList.remove("week");
  });

  var activeSections = sections.filter(function(section) {
    if (!section) {
      return false;
    }

    var time = section.querySelector("h1 time");

    if (!time) {
      return false;
    }

    var parts        = time.getAttribute("datetime").split("-"),
        sectionYear  = parseInt(parts[0], 10),
        sectionMonth = parseInt(parts[1], 10),
        sectionDay   = parseInt(parts[2].split("T")[0], 10);

    return (sectionYear >  year) ||
           (sectionYear >= year && sectionMonth >  month) ||
           (sectionYear >= year && sectionMonth >= month && sectionDay >= day);
  });

  if (activeSections.length === 0) {
    var header     = empty.querySelector("h1"),
        difference = Math.round(
          (new Date("9/16/2019").getTime() - Date.now()) /
          1000 / 60 / 60 / 24
        ),
        duration   = "in " + difference + " days";

    if (Intl.RelativeTimeFormat) {
      duration = new Intl.RelativeTimeFormat({ style: "narrow" }).format(difference, "day");
    }

    header.innerText = "Hockey " + duration + ".";

    empty.classList.remove("hidden");

    return;
  } else {
    empty.remove();
  }

  activeSections.forEach(function(section, index) {
    if (!section.querySelector("tr")) {
      return;
    } else if (count > limit && window.location.pathname === "/hockey/") {
      return;
    }

    count++;

    if (window.Intl && window.Intl.DateTimeFormat) {
      var time         = section.querySelector("h1 time");
          parts        = time.getAttribute("datetime").split("-"),
          sectionYear  = parseInt(parts[0], 10),
          sectionMonth = parseInt(parts[1], 10),
          sectionDay   = parseInt(parts[2].split("T")[0], 10);

      if (sectionYear === year && sectionMonth === month && sectionDay === day) {
        time.innerText = "Today";
      } else {
        time.innerText = Time.formatDate(
          new Date(time.getAttribute("datetime"))
        );
      }

      slice.call(section.querySelectorAll("th time")).forEach(function(time) {
        var date = new Date(time.getAttribute("datetime"));

        time.textContent = Time.formatTime(date);
      });
    }

    section.classList.add("week");
  });




  window.addEventListener("load", function(e) {
    if (!window.applicationCache) {
      return;
    }

    window.applicationCache.addEventListener("updateready", function(e) {
      if (window.applicationCache.status !== window.applicationCache.UPDATEREADY) {
        return;
      }

      if (confirm("An updated schedule is available. Load it?")) {
        window.location.reload();
      }
    }, false);
  }, false);
})();
