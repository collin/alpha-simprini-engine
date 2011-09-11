module AlphaSimprini
  module Heap
    CLASS = 0x11
    ATTRIBUTES = 0x12
    CLASSES = 0x13
    OBJECTS = 0x14
    NAMED_OBJECTS = 0x15
    LITERALS = 0x16
  
    class Packer
      attr_reader :classes, :objects, :named_objects
      def initialize
        @classes = {}
        @objects = {}
        @named_objects = {}
        @literals = []
      end
  
      def pack(object, named=nil)
        pack_object(object, pack_class(object.class), named)
      end
  
      def pack_object(object, class_reference, named=nil)
        return object.object_id if @objects[object.object_id]
        @objects[object.object_id] = reference = {} 
         if object.is_a?(Hash)
          reference.merge!\
            CLASS => class_reference,
            ATTRIBUTES => object.inject({}) {|hash, (name, object)| hash[pack(name)] = pack(object); hash }
        elsif object.is_a?(Array)
          reference.merge!\
            CLASS => class_reference,
            ATTRIBUTES => object.map{|item| pack(item) }
        elsif object.is_a?(Numeric)
          reference.merge!\
            CLASS => pack_class(Numeric),
            ATTRIBUTES => @literals.count
          @literals << object
        elsif object.is_a?(Symbol)
          reference.merge!\
            CLASS => pack_class(String),
            ATTRIBUTES => @literals.count
          @literals << object.to_s
        elsif object.is_a?(String)
          reference.merge!\
            CLASS => class_reference,
            ATTRIBUTES => @literals.count
          @literals << object
        else
          reference.merge!\
            CLASS => class_reference,
            ATTRIBUTES => (object.instance_variables.inject({}) do |hash, name|
              value_to_pack = object.instance_variable_get(name)
              if value_to_pack == object
                hash[pack(name)] = object.object_id
              else
                hash[pack(name)] = pack(value_to_pack)
              end
              hash
            end)
        end
        @named_objects[pack(named)] = object.object_id if named
        object.object_id
      end
  
      def pack_class(klass)
        @classes[klass.name] ||= @classes.size
      end
  
      def to_h
        {
          CLASSES => @classes,
          OBJECTS => @objects,
          NAMED_OBJECTS => @named_objects,
          LITERALS => @literals
        }
      end
    end
  
    class Unpacker
      attr_reader :classes, :objects, :named_objects
  
      def initialize(hash)
        @literals = hash[LITERALS]
        @classes = hash[CLASSES].inject({}) { |hash, (key, value)| hash[value] = key.constantize; hash }
        @packed_objects = hash[OBJECTS]
        @objects = {}
        @named_objects = {} 
        @packed_objects.each do |key, value|
          unpack_object(key)
        end
        hash[NAMED_OBJECTS].inject({}) do |hash, (key, value)|
          @named_objects[key] = @objects[value]
        end
      end
  
      def unpack_object(key)
        return @objects[key] if @objects[key]
        value = @packed_objects[key]
        attributes = value[ATTRIBUTES]
    
        klass = @classes[value[CLASS]]
        if klass == Hash
          @objects[key] = attributes.inject({}) do |hash, (key, value)|
            hash[unpack_object(key)] = unpack_object(value)
            hash
          end
        elsif klass == Array
          @objects[key] = attributes.map{ |item| unpack_object(item) }
        elsif klass == Numeric
          @objects[key] = @literals[attributes]
        elsif klass == String
          @objects[key] = @literals[attributes]
        elsif klass == NilClass
          @objects[key] = attributes
        else
          object = @objects[key] = klass.allocate
          attributes.each do |name, key|
            object.instance_variable_set(unpack_object(name), unpack_object(key))
          end
          object
        end
      end
    end
  end
end

if __FILE__ == $0
  require "active_support/all"
  class Thing
    attr_accessor :ace, :b, :c, :t
  
    def initialize
      @ace, @b, @c, @t = nil, nil, nil, nil
    end
  
    def inspect
      "<#Thing:#{object_id} a:#{ace.size} things b:#{b.inspect} c:#{c.inspect} t:<#Thing:#{t.to_s}> >"
    end
  end

  t = Thing.new
  t.b = "OMGt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,t"
  t.ace = [Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new,Thing.new]
  t.c = 123
  t.t = t


  include AlphaSimprini::Heap
  p = Packer.new
  p.pack(t, 'thing')
  require "msgpack"

  puts p.to_h.to_json
  # puts p.to_h.to_msgpack.bytesize
  # puts p.to_h.to_json.bytesize
  # puts MessagePack.unpack(p.to_h.to_msgpack)
  # MessagePack.unpack(p.to_h.to_msgpack)
  # puts Unpacker.new(MessagePack.unpack(p.to_h.to_msgpack)).named_objects['thing'].t.inspect
  # puts Unpacker.new(MessagePack.unpack(p.to_h.to_msgpack)).named_objects['thing'].ace.first.inspect
end