class String
  def uniquify(others=[])
    def suffix(others)
      suffix = ""
      i = 0
      while others.include?(self + suffix)
        i += 1
        suffix = i.to_s
      end

      return suffix
    end

    return self + suffix(others)
  end
end
