defmodule PowerAssert.Ast do
  @moduledoc """
  this module is deprecated.

  It will be replaced with `Macro.traverse` at the timing to cut support for v1.0.x and v1.1.x
  """

  # almost from elixir source
  def traverse(ast, acc, pre, post) when is_function(pre, 2) and is_function(post, 2) do
    {ast, acc} = pre.(ast, acc) 
    do_traverse(ast, acc, pre, post)
  end

  defp do_traverse({form, meta, args}, acc, pre, post) do
    {form, acc} =
      case is_atom(form) do
        false ->
          {form, acc} = pre.(form, acc)
          do_traverse(form, acc, pre, post)
        true ->
          {form, acc}
      end

    {args, acc} =
      case is_atom(args) do
        false ->
          Enum.map_reduce(args, acc, fn x, acc ->
            {x, acc} = pre.(x, acc)
            do_traverse(x, acc, pre, post)
          end)
        true ->
          {args, acc}
      end

    post.({form, meta, args}, acc)
  end  

  defp do_traverse({left, right}, acc, pre, post) do
    {left, acc} = pre.(left, acc) 
    {left, acc} = do_traverse(left, acc, pre, post)
    {right, acc} = pre.(right, acc)
    {right, acc} = do_traverse(right, acc, pre, post)
    post.({left, right}, acc)
  end

  defp do_traverse(list, acc, pre, post) when is_list(list) do
    {list, acc} = Enum.map_reduce(list, acc, fn x, acc ->
      {x, acc} = pre.(x, acc)
      do_traverse(x, acc, pre, post)
    end)
    post.(list, acc)
  end

  defp do_traverse(x, acc, _pre, post) do
    post.(x, acc)
  end
end
