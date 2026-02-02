/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.classes.volume;

import uim.docker;

@safe:

// Volume resource wrapper
class DockerVolume {
    this() {
        _data = Json.emptyObject;
    }

    this(Json data) {
        this.data = data;
    }

    protected Json _data;
    @property Json data() const @trusted {
        return _data;
    }

    @property void data(Json value) @trusted {
        _data = value;
    }

    string name() const @trusted {
        if (auto n = "Name" in data.object) {
            return n.toString;
        }
        return "";
    }

    string driver() const @trusted {
        if (auto d = "Driver" in data.object) {
            return d.toString;
        }
        return "";
    }

    Json mountpoint() const @trusted {
        if (auto m = "Mountpoint" in data.object) {
            return *m;
        }
        return Json("");
    }

    Json labels() const @trusted {
        if (auto l = "Labels" in data.object) {
            return *l;
        }
        return Json.emptyObject;
    }
}
