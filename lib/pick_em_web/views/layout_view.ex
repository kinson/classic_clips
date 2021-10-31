defmodule PickEmWeb.LayoutView do
  use PickEmWeb, :view

  def clips("Classic Clips") do
    "clips selected"
  end

  def clips(_) do
    "clips"
  end

  def classics("Classics") do
    "classics selected"
  end

  def classics(_) do
    "classics"
  end
end
