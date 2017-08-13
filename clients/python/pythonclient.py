import inspect
import threading
from uuid import uuid4


thread_local = threading.local()


def label_and_find_in_stack(func):
    def func_wrapper():
        frame = inspect.currentframe()
        curr_id = str(uuid4())
        frame_stack = getattr(thread_local, 'frame_stack', None)
        if not frame_stack:
            thread_local.frame_stack = [curr_id]
        else:
            thread_local.frame_stack.append(curr_id)
        print("wrapped {} thread_local stack {}".format(
            func.__name__, thread_local.frame_stack))
        return func()
    return func_wrapper


@label_and_find_in_stack
def other_labelled_function():
    pass


def function_that_does_something_else():
    other_labelled_function()


@label_and_find_in_stack
def function_that_does_thing():
    function_that_does_something_else()


def main():
    function_that_does_thing()


if __name__ == "__main__":
    main()
