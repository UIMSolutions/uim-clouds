module uim.kubernetes.interfaces.service;

import uim.kubernetes;

mixin(ShowModule!());

@safe:

interface IK8SService {
  string name() const;

  string namespace_() const;

  Json spec() const;

  string serviceType() const;

  Json[] ports() const;
}
