class Response<T> {
  Status status;
  T responseBody;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.responseBody) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $responseBody";
  }
}

enum Status { LOADING, COMPLETED, ERROR }