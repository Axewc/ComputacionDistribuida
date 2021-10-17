defmodule Module1 do

  @doc """
    Implementación de fibonacci. Para esta función se uso case, para saber
    cual saber que caso debe aplicar de la función recursiva. Esto por que
    necesitamos llegar a los casos base.

    (Se pudo implementar también con casa de patrones directo a las funcio-
    nes.)

    Adicionalmente checa que la entrada sea un número y que sea positivo.
  """
  def fibonacci(n) do
    case n do
      0 -> 0
      1 -> 1
      n ->
        if n > 1 && is_number(n) do
          fibonacci(n-1) + fibonacci(n-2)
        else
          IO.puts("La entrada #{inspect n} es inválida.")
          :error
        end
    end
  end

  @doc """
    El factorial de n, es el producto de los n números.

    Se implemento usando casa de patrones, donde según la entrada cazará con
    alguna de las definiciones para la función.

    Se definio el caso para 0 y para 1. Convencionalmente 1, es el caso base,
    pero si solo definimos este caso, quedaría indefinido el 0.

    Para el caso de n, hace la misma evaluación que en el caso anterior.
  """
  def factorial(0), do: 1
  def factorial(1), do: 1
  def factorial(n) do
    if n > 1 && is_number(n) do
      n * factorial(n-1)
    else
      IO.puts("La entrada #{inspect n} es inválida.")
      :error
    end
  end

  @doc """
    Obtiene un número aleatorio entre el 1 y el n.

    Calcula cual es la probabilidad de cada uno de los números en ese rango
    prob_num. Entonces calcula cual es la probabilidad de aparición de todo
    el rango [k .. n].
  """
  def random_probability(n) do
    #Dado un número n, escoger un número aleatorio en el rango [1, n], digamos k
    #y determinar cuál es la probabilidad de que salga un número aleatorio
    #entre [k, n], el chiste obtener el número aleatorio.
    k = :rand.uniform(n)
    IO.puts("Número aleatorio seleccionado: #{inspect k}")
    prob_num = 1 / n
    prob_k = ((n - k) * prob_num) + 0.1
    IO.puts("La probabilidad de que salga un número entre k y n es de #{inspect prob_k}")
  end

  @doc """
    Va a separar los digitos del número.

    Primero, vérifica que la entrada sea un número.

    Luego, sí el número es negativo, va a añadir un atómico que represente
    el signo - y va a continuar su ejecución con el valor absoluto del nú-
    mero.

    Si el número ya es un digito, es decir n < 10. Devuelve la lista con
    ese dígito (Se tuvo que implementar la conversión, por que, al meter
    n a la lista, Elixir lo transformaba automáticamente a ASCII).

    Si el número aún no es un digito. Va a separar el último dígito del
    número (que va a caer en el caso base), y va a separar el resto del
    número. Así hará recursión sobre ambos,  concatenará la lista que
    obtenga de esta llamada.
  """
  def digits(n) do
    cond do
      ! is_number(n) ->
        IO.puts("#{inspect n} no es un número.")
        :error
      n < 0 ->
        [:-] ++ digits(abs(n))
      n < 10 ->
        n = Integer.to_string(n)
        n = Integer.parse(n)
        {var, _} = n
        [var]
      n ->
        digits(div(n,10)) ++ digits(rem(n,10))
    end
  end

end

defmodule Module2 do

  @doc """
    Función test.
  """
  def test do
    fn -> end
    :ok
  end

  @doc """
    Función auxiliar quecalcula el MCD mediante una implementación del Al-
    goritmo de Euclides.
  """
  defp mcd(x,y) do
    case y do
      0 -> x
      y -> mcd(y,rem(x,y))
    end
  end

  @doc """
    La forma en la que podemos saber si la ecuación a x ~= b mod n. Es caculando el mcd de a y n, si
    este es 1, significa que a y n son primos relativos y por lo tanto tienen solución. En otro caso
    significa que no son primos relativos y que la ecuación no tiene solución.

    Para esto, se usará la función auxiliar.

    (~= representa el símbolo de congruencia).
  """
  def solve(a,b,n) do
    if mcd(a,n) == 1 do
      "La ecuación #{inspect a} x ~= #{inspect b} mod #{inspect n} tiene solución."
    else
      "La ecuación #{inspect a} x ~= #{inspect b} mod #{inspect n} no tiene solcuión."
    end
  end
end

defmodule Module3 do

  @doc """
    Función que busca exhaustivamente si el elemento x se encuentra dentro
    de la lista [y|ys].
  """
  def is_rep(x,[]), do: false
  def is_rep(x,[y | ys]) do
    if x == y do
      true
    else
      is_rep(x,ys)
    end
  end

  @doc """
    Generá una lista auxiliar sin repeticiones. Para esto busca si el
    elemento no ha sido ya añadido a la lista auxiliar.

    Si el elemento no ha sido explorado, lo agrega a la lista y sigue
    buscando sobre la lista original. Los elementos que descubra que
    ya ha revisado, los va a ignorar.
  """
  def sin_rep([],l), do: l
  def sin_rep([x|xs],l) do
    if is_rep(x,l) do
      sin_rep(xs,l)
    else
      sin_rep(xs, l ++ [x])
    end
  end

  @doc """
    Para la implementación se va a recurrir a crear una lista auxiliar
    (que inicializa en vacía), donde va a agregar los elementos que no
    hayan aparecido en la lista original.
  """
  def elim_dup(l) do
    l = sin_rep(l, [])
  end

  @doc """
    Calcula los primos en los primeros 100 números. Para esto, se va a
    hacer uso de 3 estrcutras auxiliares. Una lista con los números en
    el rango 2 a n. Una lista que guardará a los primos encontrados, y
    una lista que guardará a los números compuestos que se generen.
  """
  def sieve_of_erathostenes(n) do
    if n < 2 do
      "La entrada es inválida."
    else
      rango = 2 .. n
      nums = Enum.to_list(rango)
      prims = []
      comps = []
      prims = sieve_of_erathostenes_recursion(nums, prims, comps)
    end
  end

  @doc """
    Función auxiliar, va a recorrer la lista en el rango 2 a n,
    y va a vérificar que el elemento en la cabeza n, no sea un
    número compuesto.

    Si esto se cumple, va a agregar a x a los números primos, y
    va a descubrir los números compuestos que génera en la lista
    orginal. Esto es, aplicando módulo, utilizando la función de
    Enum, filter.

    Adicionalmente, eliminara de la lista original todos los ele-
    mentos que sean compuestos, para evitar tener que evaluarlos
    nuevamente. Esto mejora ligeramente la eficienca.
  """
  def sieve_of_erathostenes_recursion([], prims, _), do: prims
  def sieve_of_erathostenes_recursion([x | xs], prims, comps) do
    if !(x in  comps) do
      prims = prims ++ [x]
      comps = comps ++ Enum.filter(xs, fn y -> (rem(y,x) == 0) && !(y in comps) end)
      xs = Enum.filter(xs, fn x -> !(x in comps) end)
      sieve_of_erathostenes_recursion(xs, prims, comps)
    else
      sieve_of_erathostenes_recursion(xs, prims, comps)
    end
  end

end

defmodule Module4 do

  def monstructure() do
    pid = spawn(fn -> server end)
    #send(pid, {:delete, :list, self(), 1})
    #send(pid, {:put, :list, self(), 5})
    #send(pid, {:length, :list, self()})
    receive do
      {:ok, :delete, :list} ->
        "Se elimino correctamente el elemento de la lista."
      {:ok, :put, :list} ->
        "Se agrego el elemento a la lista."
      {:ok, :lenght, :list, length} ->
        "El tamaño de la lista es #{inspect length}."
    after
      10_000 -> "Se rebaso el tiempo de espera."
    end
  end

  # {:petición, :estructura, remitente, <elementos>}
  def server() do
    l = [1,2,3,4]
    t = {}
    m = Map.new()
    ms = MapSet.new()
    receive do
      {:delete, :list, rem, elem} ->
        l = List.delete(l,elem)
        send(rem, {:ok, :delete, :list})
      {:put, :list, rem, elem} ->
        l ++ [elem]
        send(rem, {:ok, :put, :list})
      {:length, :list, rem} ->
        length = length(l)
        send(rem, {:ok, :length, :list, length})
    end
  end

end
