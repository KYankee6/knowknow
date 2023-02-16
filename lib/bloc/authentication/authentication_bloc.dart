import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../repositories/userRepository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {

  final UserRepository _userRepository;
  
  AuthenticationBloc({required UserRepository userRepository})
      :assert(userRepository != null),
      _userRepository = userRepository;

  AuthenticationBloc() : super(Uninitialized()) {
    on<AuthenticationEvent>((event, emit) {
      // TODO: implement event handler
      if(event is AppStarted){
        yield* _mapAppstartedToState();
      } else if (event is LoggedIn){
        yield* _mapLoggedInToState()
      }else if(event is LoggedOut) {
        yield* _mapLoggedOutToState()

      }
    });
  }

  Stream<AuthenticationState> _mapAppstartedToState()
  async*{
    try{
      final isSignedIn = await _userRepository.isSingedIn();
      if(isSignedIn){
        final uid = await _userRepository.getUser();
        final isFirstTime = await _userRepository.isFirstTime(uid);

        if(isFirstTime) {
          yield AuthenticatedButNotSet(uid);
        } else{
          yield Authenticated(uid);
        }
      } else{
        yield UnAuthenticated();
      }
    } catch (_) {
      yield UnAuthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async*{
    final isFirstTime = await _userRepository.isFirstTime(await _userRepository.getUser());
    if(!isFirstTime) {
      yield AuthenticatedButNotSet(await _userRepository.getUser());
    }else{
      yield Authenticated(await _userRepository.getUser());

    }
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield UnAuthenticated();
    _userRepository.signOut();

  }
}
