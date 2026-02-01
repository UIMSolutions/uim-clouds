module uim.kubernetes.interfaces.resource;

interface IK8SResource {
    Json data() const;
    IK8SResource data(Json value);

    string name() const;

    string namespace_() const;

    string kind() const;

    string apiVersion() const;

    Json metadata() const;

    Json spec() const;

    Json status() const;
}
