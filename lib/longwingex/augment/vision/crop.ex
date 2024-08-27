defmodule Longwingex.Augment.Vision.Crop do
  alias Longwingex.Augment.Vision.Coerce

  def crop(image_set, padding, random_key) do
    # Determine crop_shape, i.e. orig image x, y
    {batch_size_like, crop_x, crop_y, _channels} =
      Coerce.batch_shape_like(image_set)

    # Determine the starting position
    {rand_x, new_random_key} = Nx.Random.uniform(random_key)
    {rand_y, new_random_key} = Nx.Random.uniform(new_random_key)

    start_x =
      (Nx.to_number(rand_x) * padding + 0.5)
      |> trunc()

    start_y =
      (Nx.to_number(rand_y) * padding + 0.5)
      |> trunc()

    pad_config =
      pad_config(batch_size_like, padding)

    {slice_start_indices, slice_lengths} =
      slice_config(batch_size_like, {start_x, start_y}, {crop_x, crop_y})

    aug_img_set =
      Nx.pad(image_set, 0, pad_config)
      |> Nx.slice(slice_start_indices, slice_lengths)

    {aug_img_set, new_random_key}
  end

  defp pad_config(batch_size_like, padding) do
    cond do
      batch_size_like == 0 ->
         [{padding, padding, 0}, {padding, padding, 0}, {0, 0, 0}]
      true ->
        [{0, 0, 0}, {padding, padding, 0}, {padding, padding, 0}, {0, 0, 0}]
    end
  end

  defp slice_config(batch_size_like, {start_x, start_y}, {crop_x, crop_y}) do
    cond do
      batch_size_like == 0 ->
         {[start_x, start_y, 0], [crop_x, crop_y, 1]}
      true ->
        {[0, start_x, start_y, 0], [batch_size_like, crop_x, crop_y, 1]}
    end
  end
end
