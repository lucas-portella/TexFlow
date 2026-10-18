import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/services/api_client.dart';

Map<String, dynamic> _usuarioSalvo({String? token}) => {
  'idUsuario': 7,
  'nome': 'Ana',
  'email': 'ana@texflow.com',
  'senha': '',
  'tipo': 'GESTOR',
  'cargo': null,
  'token': token,
  'empresaId': 1,
  'donoDaEmpresa': true,
  'modulos': <String>[],
};

void main() {
  const cofre = FlutterSecureStorage();

  setUp(() {
    Sessao.token = null;
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('sessão guardada pelo app novo: token no cofre, fora das preferências', () async {
    SharedPreferences.setMockInitialValues({
      'usuario': jsonEncode(_usuarioSalvo()),
    });
    FlutterSecureStorage.setMockInitialValues({'token': 'token-do-cofre'});

    final provider = UsuarioProvider();
    await provider.carregarUsuarioSalvo();

    expect(provider.logado, isTrue);
    expect(provider.usuario!.token, 'token-do-cofre');
    expect(Sessao.token, 'token-do-cofre');
  });

  test('sessão da versão anterior é migrada para o cofre', () async {
    SharedPreferences.setMockInitialValues({
      'usuario': jsonEncode(_usuarioSalvo(token: 'token-antigo')),
    });

    final provider = UsuarioProvider();
    await provider.carregarUsuarioSalvo();

    expect(Sessao.token, 'token-antigo');
    expect(await cofre.read(key: 'token'), 'token-antigo');

    final prefs = await SharedPreferences.getInstance();
    final guardado = jsonDecode(prefs.getString('usuario')!);
    expect(guardado.containsKey('token'), isFalse);
  });

  test('sem token em lugar nenhum, a sessão é descartada', () async {
    SharedPreferences.setMockInitialValues({
      'usuario': jsonEncode(_usuarioSalvo()),
    });

    final provider = UsuarioProvider();
    await provider.carregarUsuarioSalvo();

    expect(provider.logado, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('usuario'), isNull);
  });

  test('sair apaga o usuário e o token do cofre', () async {
    SharedPreferences.setMockInitialValues({
      'usuario': jsonEncode(_usuarioSalvo()),
    });
    FlutterSecureStorage.setMockInitialValues({'token': 'token-do-cofre'});

    final provider = UsuarioProvider();
    await provider.carregarUsuarioSalvo();
    await provider.logout();

    expect(provider.logado, isFalse);
    expect(Sessao.token, isNull);
    expect(await cofre.read(key: 'token'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('usuario'), isNull);
  });

  test('o usuário salvo não leva o token junto', () async {
    final usuario = Usuario.fromMap(_usuarioSalvo(token: 'abc'));
    expect(usuario.token, 'abc');
    expect(usuario.toMap()..remove('token'), isNot(contains('token')));
  });
}
