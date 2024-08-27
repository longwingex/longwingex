defmodule Longwingex.Augment.Vision.Coerce do
  def batch_shape_like(image_or_batch) do
    true_shape = Nx.shape(image_or_batch)

    size_rank =
      true_shape
      |> tuple_size()

    cond do
      size_rank == 3 ->
        {x, y, channels} = true_shape
        {0, x, y, channels}

      true ->
        true_shape
    end
  end
end
