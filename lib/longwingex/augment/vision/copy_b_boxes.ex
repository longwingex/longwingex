defmodule Longwingex.Augment.Vision.CopyBBoxes do
  alias Longwingex.Augment.Vision.Coerce

  def copy_bboxes(image_set, box_percent, max_boxes, random_key) do
    size_rank = tuple_size(Nx.shape(image_set))
    case size_rank do
      rank when rank in [3,4] ->
        copy_n_boxes(image_set, box_percent, max_boxes, random_key)
      _ ->
        {image_set, random_key}
    end
  end

  defp copy_n_boxes(image_or_batch, box_percent, max_boxes, random_key) do
    {rand_box_nbr, new_random_key} = Nx.Random.uniform(random_key)
    offset = 1
    nbr_boxes =
      Nx.to_number(rand_box_nbr) * max_boxes + offset
      |> trunc()

    # The size of the portion of the original image that can be the
    # start of the source and destination bounding pixel box
    {batch_size_like, x, y, channels} =
      Coerce.batch_shape_like(image_or_batch)
    start_size = {trunc(x * (1 - box_percent)), trunc(y * (1 - box_percent))}

    cond do
      batch_size_like == 0 ->
        image_copy_n_boxes(image_or_batch, batch_size_like, nbr_boxes,
          start_size, channels, box_percent, new_random_key)

      true ->
        batch_copy_n_boxes(image_or_batch, batch_size_like, nbr_boxes,
                    start_size, channels, box_percent, random_key)
    end
  end

  defp batch_copy_n_boxes(image_batch, batch_size_like, nbr_boxes,
                    start_size, channels, box_percent, random_key) do
    acc = %{image_or_batch: image_batch, random_key: random_key}
    %{image_or_batch: aug_img_or_batch, random_key: aug_random_key} =
      Enum.reduce(1..batch_size_like, acc, fn(batch_idx, acc) ->
        {aug_image, aug_random_key} =
          image_copy_n_boxes(image_batch, batch_idx, nbr_boxes, start_size, channels,
            box_percent, acc.random_key)
        %{image_or_batch: aug_image, random_key: aug_random_key}
      end)
    {aug_img_or_batch, aug_random_key}
  end

  defp image_copy_n_boxes(
    image_or_batch, batch_index, nbr_boxes,
    start_size, channels, box_percent, random_key) do
      acc = %{image: image_or_batch, random_key: random_key}
      %{image: aug_image, random_key: new_random_key} =
        Enum.reduce(1..nbr_boxes, acc, fn(_box_index, acc) ->
          {start_location, new_random_key} =
            random_location(batch_index, start_size, channels, acc.random_key )
          {dest_location, new_random_key2} =
            random_location(batch_index, start_size, channels, new_random_key )
          box_size =
            bounding_box_size(image_or_batch, batch_index, box_percent)
          source_pixels = Nx.slice(acc.image, start_location, box_size)
          aug_image = Nx.put_slice(acc.image, dest_location, source_pixels)
          %{image: aug_image, random_key: new_random_key2}
        end)
    {aug_image, new_random_key}
  end

  defp random_location(batch_index, start_size, channels, random_key) do
    {rand_x, new_random_key} = Nx.Random.uniform(random_key)
    {rand_y, new_random_key} = Nx.Random.uniform(new_random_key)
    start_x =
      (Nx.to_number(rand_x) * elem(start_size, 0))
      |> trunc()
    start_y =
      (Nx.to_number(rand_y) * elem(start_size, 1))
      |> trunc()
    location =
      cond do
        batch_index == 0 ->
          [start_x, start_y, channels - 1]
        true ->
          [batch_index, start_x, start_y, channels - 1]
    end
    {location, new_random_key}
  end

  defp bounding_box_size(image_or_batch, batch_index, box_percent) do
    {_batch_size, x, y, _channels}
      = Coerce.batch_shape_like(image_or_batch)
    case batch_index do
      0 ->
        [trunc(x * box_percent), trunc(y * box_percent), 1]
      _ ->
        [batch_index, trunc(x * box_percent), trunc(y * box_percent), 1]
    end
  end

end
