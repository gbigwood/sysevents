import inspect
import threading
from uuid import uuid4


THREAD_LOCAL = threading.local()  # 🙈 Each call gets a view so must be global or passed in 🙈 


def _find_parent_id(thread_locals):
    if len(thread_locals.frame_stack):
        return thread_locals.frame_stack[-1]
    else:
        return None


def _save_current_frame(thread_locals):
    curr_id = str(uuid4())
    # can't add attributes to frames cause they are wrappers for C (interpreter implementation specific)
    thread_locals.frame_stack.append(curr_id)
    print("pushed", curr_id)
    return curr_id


def _construct_frame_stack(thread_locals):
    frame_stack = getattr(thread_locals, 'frame_stack', None)
    if not frame_stack:
        thread_locals.frame_stack = []


def _pop_stack(thread_locals):
    thread_locals.frame_stack.pop()


def _save_on_server(parent_id, current_id):
    print("saved", parent_id, current_id)


def label_and_find_in_stack(func):
    # You're not supposed to recurse in python so it's all good :)
    def func_wrapper():
        _construct_frame_stack(THREAD_LOCAL)
        parent_id = _find_parent_id(THREAD_LOCAL)
        current_id = _save_current_frame(THREAD_LOCAL)
        _save_on_server(parent_id, current_id)
        result = func()
        _pop_stack(THREAD_LOCAL)
        return result
    return func_wrapper


############################


@label_and_find_in_stack
def other_labelled_function():
    pass


@label_and_find_in_stack
def some_other_branch():
    pass


def function_that_does_something_else():
    other_labelled_function()
    some_other_branch()


@label_and_find_in_stack
def function_that_does_thing():
    function_that_does_something_else()


def main():
    function_that_does_thing()


if __name__ == "__main__":
    main()
