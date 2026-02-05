/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.namespaces.manager;

import core.sys.posix.unistd : close;
import std.exception : enforce;
import std.format : format;

import uim.namespaces.types;
import uim.namespaces.syscalls;
import uim.namespaces.inspector;

@trusted:

