import 'package:jinja/jinja.dart';
import 'package:reflectable/reflectable.dart';

import 'main.reflectable.dart';

class Reflector extends Reflectable {
  const Reflector() : super(invokingCapability);
}

const Reflector reflector = Reflector();

@reflector
class User {
  User({this.fullname, this.email});

  String? fullname;

  String? email;
}

Object? fieldGetter(Object? object, String field) {
  return reflector.reflect(object!).invokeGetter(field);
}

void main() {
  initializeReflectable();

  final env = Environment(
    globals: {
      'now': () {
        DateTime dt = DateTime.now().toLocal();
        String hour = dt.hour.toString().padLeft(2, '0');
        String minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      },
    },
    loader: MapLoader({
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
    fieldGetter: fieldGetter,
  );

  Template template = env.getTemplate('users');

  print(template.render({
    'users': <User>[
      User(fullname: 'Jhon Doe', email: 'jhondoe@dev.py'),
      User(fullname: 'Jane Doe', email: 'janedoe@dev.py'),
    ]
  }));
}
