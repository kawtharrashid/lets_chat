abstract interface class UseCase<Output, Input> {
  Output call(Input input);
}

abstract interface class NoParamsUseCase<Output> {
  Output call();
}
