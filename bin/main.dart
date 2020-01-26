import 'package:jinja/jinja.dart';
import 'package:reflectable/reflectable.dart';

import 'main.reflectable.dart';

class JinjaReflectable extends Reflectable {
  const JinjaReflectable() : super(invokingCapability);
}

const JinjaReflectable jinjaReflectable = JinjaReflectable();

void main() {
  initializeReflectable();

  Environment env = Environment(
    globals: <String, Object>{
      'now': () {
        DateTime dt = DateTime.now().toLocal();
        String hour = dt.hour.toString().padLeft(2, '0');
        String minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      },
    },
    loader: MapLoader(<String, String>{
      'base': '''{% block title %}Title{% endblock %}
{% block content %}Content{% endblock %}''',
      'users': '''{% extends "base" %}
{% block title %}
  {{ super() }}: users, {{ now() }}
{% endblock %}
{% block content %}
  {% for user in users %}
    {{ user.fullname }}, email: {{ user.email }}
  {% else %}
    No users
  {% endfor %}
{% endblock %}''',
    }),
    leftStripBlocks: true,
    trimBlocks: true,
    getField: getField,
  );

  Template template = env.getTemplate('users');

  print(template.render(users: <User>[
    User(fullname: 'Jhon Doe', email: 'jhondoe@dev.py'),
    User(fullname: 'Jane Doe', email: 'janedoe@dev.py'),
  ]));
}

@jinjaReflectable
class User {
  User({this.fullname, this.email});

  String fullname;
  String email;
}

Object getField(Object obj, String field) => jinjaReflectable.reflect(obj).invokeGetter(field);
